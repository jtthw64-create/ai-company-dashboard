#!/bin/bash
# com.aicompany.dispatcher-poller — AI Company 접수함 나노 폴러
# ★사본(FIX-01, 2026-07-12) — Gist ID는 <COMPANY_GIST_ID> 플레이스홀더로 마스킹됨.
#   실물은 nurisimac의 ~/.aicompany/dispatcher-poller.sh. 재구축 절차는 docs/ops/ENGINE.md §5.
# launchd가 60초마다 기동. gist의 status=="new" 요청이 있을 때만 claude -p 디스패처 실행.
# 유휴 회차 비용: GitHub GET 1회(ETag 304 = rate limit 미차감·바디 0), LLM 비용 0.
set -u

GH=/opt/homebrew/bin/gh
JQ=/usr/bin/jq
CLAUDE=/opt/homebrew/bin/claude
CO="/Users/<USERNAME>/Library/CloudStorage/Dropbox/Claude Dropbox/AI Company"
GIST_ID="<COMPANY_GIST_ID>"
GIST_FILE="company-status.json"

BASE="$HOME/.aicompany"; STATE="$BASE/state"
LOGDIR="$HOME/Library/Logs/aicompany"; LOG="$LOGDIR/poller.log"
RUNLOG_PREFIX="$LOGDIR/dispatch"
LOCKDIR="$STATE/poller.lock.d"; ETAG_F="$STATE/gist.etag"; BODY_F="$STATE/gist.body.json"
FAIL_F="$STATE/backoff"; HASH_F="$STATE/last-new"
DISPATCH_LOCK="$CO/.dispatch.lock"

CLAUDE_TIMEOUT=1500        # 25분 — dev.verify 빌드 포함 상한 (timeout(1) 부재 → 수동 워치독)
STALE_POLLER_LOCK=2700     # 45분
DISPATCH_LOCK_FRESH=2700   # 스킬의 스테일 기준(45분)과 동기화
FAIL_BACKOFF=600           # 실패 후 10분
STALL_BACKOFF=1800         # 같은 new 집합 3회 무진전 시 30분
MAX_STREAK=3

log(){ printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG"; }
mkdir -p "$STATE" "$LOGDIR"
[ -f "$LOG" ] && [ "$(stat -f%z "$LOG" 2>/dev/null || echo 0)" -gt 5242880 ] && mv -f "$LOG" "$LOG.old"

# 0. 폴러 자체 락 (launchd 단일 인스턴스의 2중 안전판)
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  ts=$(cat "$LOCKDIR/ts" 2>/dev/null || echo 0)
  if [ $(( $(date +%s) - ${ts:-0} )) -gt "$STALE_POLLER_LOCK" ]; then
    rm -rf "$LOCKDIR"; mkdir "$LOCKDIR" 2>/dev/null || exit 0
    log "WARN stale poller lock cleared"
  else exit 0; fi
fi
date +%s > "$LOCKDIR/ts"; trap 'rm -rf "$LOCKDIR"' EXIT

# 1. 다른 디스패처(앱 정기 회차·수동 세션) 작업 중이면 무비용 스킵
if [ -f "$DISPATCH_LOCK" ]; then
  lts=$(cat "$DISPATCH_LOCK" 2>/dev/null || echo "")
  case "$lts" in (''|*[!0-9]*) lts=$(stat -f%m "$DISPATCH_LOCK" 2>/dev/null || echo 0);; esac
  [ $(( $(date +%s) - lts )) -lt "$DISPATCH_LOCK_FRESH" ] && exit 0
fi

# 2. backoff 게이트
now=$(date +%s)
if [ -f "$FAIL_F" ]; then
  read -r _fc funtil < "$FAIL_F" 2>/dev/null || funtil=0
  [ "$now" -lt "${funtil:-0}" ] && exit 0
fi

# 3. gist 조회 — curl + gh auth token + ETag (304 = rate limit 미차감)
TOKEN=$("$GH" auth token 2>/dev/null) || { log "ERR gh auth token failed (keychain?)"; exit 0; }
etag=$(cat "$ETAG_F" 2>/dev/null || true)
hdr=$(mktemp "${TMPDIR:-/tmp}/aicompany-poller.XXXXXX")
code=$(curl -sS --max-time 15 -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  ${etag:+-H "If-None-Match: $etag"} -D "$hdr" -o "$BODY_F.tmp" -w '%{http_code}' \
  "https://api.github.com/gists/$GIST_ID" 2>>"$LOG") || { rm -f "$hdr" "$BODY_F.tmp"; log "ERR curl transport"; exit 0; }
case "$code" in
  304) rm -f "$hdr" "$BODY_F.tmp"; exit 0 ;;
  200) awk 'tolower($1)=="etag:"{print $2}' "$hdr" | tr -d '\r' > "$ETAG_F"
       mv -f "$BODY_F.tmp" "$BODY_F"; rm -f "$hdr" ;;
  *)   rm -f "$hdr" "$BODY_F.tmp"; log "ERR gist HTTP $code"; exit 0 ;;
esac

# 4. 실행 요청 카운트 — ★새로고침은 실행이 아님(company.refresh 제외), queued(앱 정기 회차 몫)도 제외
#    사용자가 [실행] 버튼으로 보낸 진짜 작업 요청(status=new)만 폴러를 깨운다.
new_ids=$("$JQ" -r --arg f "$GIST_FILE" \
  '.files[$f].content | fromjson | [.requests[]? | select(.status=="new" and .action != "company.refresh") | .id] | sort | join(",")' \
  "$BODY_F" 2>/dev/null) || { log "ERR jq parse"; exit 0; }
[ -z "$new_ids" ] && { rm -f "$HASH_F"; exit 0; }

# 5. 무진전 감지: 같은 new 집합 3회 연속이면 30분 backoff (비용 폭주 차단)
prev=$(cat "$HASH_F" 2>/dev/null || true); streak=1
[ "${prev%% *}" = "$new_ids" ] && streak=$(( ${prev##* } + 1 ))
if [ "$streak" -gt "$MAX_STREAK" ]; then
  echo "0 $(( now + STALL_BACKOFF ))" > "$FAIL_F"; echo "$new_ids 0" > "$HASH_F"
  log "WARN no-progress on [$new_ids] x${MAX_STREAK} — backoff ${STALL_BACKOFF}s"; exit 0
fi
echo "$new_ids $streak" > "$HASH_F"

# 6. claude 디스패처 기동 (cwd=$CO → 회사 CLAUDE.md 로드)
RUNLOG="$RUNLOG_PREFIX-$(date +%Y%m%d).log"
log "SPAWN new=[$new_ids] streak=$streak"
cd "$CO" || { log "ERR cd CO"; exit 0; }
{ echo "===== $(date '+%F %T') spawn new=[$new_ids] ====="; } >> "$RUNLOG"
# ★잠금 도구함 + 검문소 끄기:
#   PATH="$BASE/bin" → claude의 Bash 하위 명령이 안전 도구함(제한된 명령셋)만 봄. python·curl·
#   node·ssh·bash·mv 등 위험 도구는 이 PATH에 없어 OS 레벨 차단.
#   --dangerously-skip-permissions → launchd(앱 바깥)는 앱 권한 검문소에 연결 못 해
#   Bash가 전면 차단되므로 이 모드로만 실행 가능. 안전은 [잠금 도구함 + 스킬 불가침
#   금지목록] 두 겹이 담당.
# ★--setting-sources user: CLI 2.1.207부터 사용자 스킬(~/.claude/skills) 로딩이
#   user 설정 소스에 묶임 — ""(무설정)이면 dispatch-inbox가 안 보여 전 무인 레인이
#   멈춘 회귀가 실측됨(2026-07-11). 프롬프트에 SKILL.md 직독 폴백도 추가(버전 변화 내성).
PATH="$BASE/bin" "$CLAUDE" -p "dispatch-inbox 스킬을 실행해 접수함을 1회 처리하라. (만약 스킬이 목록에 없으면 ~/.claude/skills/dispatch-inbox/SKILL.md 파일을 직접 읽어 그 절차를 그대로 수행하라.) 질문 금지(무인·헤드리스). 처리할 것이 없으면 침묵 종료." \
  --dangerously-skip-permissions --setting-sources user \
  --strict-mcp-config --model sonnet --max-budget-usd 2 --output-format text >> "$RUNLOG" 2>&1 &
CPID=$!
( sleep "$CLAUDE_TIMEOUT"; kill -0 "$CPID" 2>/dev/null && { kill -TERM "$CPID" 2>/dev/null; sleep 10; kill -KILL "$CPID" 2>/dev/null; } ) &
WPID=$!
wait "$CPID"; RC=$?
pkill -P "$WPID" 2>/dev/null; kill "$WPID" 2>/dev/null

if [ "$RC" -eq 0 ]; then rm -f "$FAIL_F"; log "DONE rc=0"
else
  # ★ETag 롤백: ETag는 200 직후(spawn 전) 저장되므로, 디스패처가 실패하면 처리
  #   안 된 요청이 남은 채 ETag만 최신이라 다음 폴이 304로 건너뛴다. 실패 시 ETag를
  #   지워 backoff 후 재시도가 반드시 fresh GET(200)→재처리되게 한다.
  rm -f "$ETAG_F"
  fc=0; [ -f "$FAIL_F" ] && read -r fc _ < "$FAIL_F" 2>/dev/null
  fc=$(( ${fc:-0} + 1 )); echo "$fc $(( $(date +%s) + FAIL_BACKOFF ))" > "$FAIL_F"
  log "FAIL rc=$RC — backoff ${FAIL_BACKOFF}s (count=$fc)"
fi
exit 0
