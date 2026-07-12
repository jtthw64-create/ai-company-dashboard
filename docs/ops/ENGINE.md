# ENGINE.md — 실행 엔진 역문서화

> FIX-01 산출물. V-01(엔진 실물 확인)의 결과를 반영한다. "이 문서만 보고 새 맥에서 엔진 재현 가능한가?"가 검증 기준.
> Gist ID·토큰은 여기 쓰지 않는다 — `Dropbox: Claude Dropbox/AI Company/gist-config.md` 참조.

## 1. 엔진 구성 요소 (V-01 실측, 2026-07-12)

디스패처(로컬 폴러)는 **두 개의 독립 레인**으로 구성된다. 둘 다 nurisimac(iMac)에만 존재 — 이 repo나 원격 세션에는 없다.

### 레인 A — launchd 나노 폴러 (60초 폴링, 버튼 즉시 반응)
- **실체**: `launchd` LaunchAgent, plist `~/Library/LaunchAgents/com.aicompany.dispatcher-poller.plist`(`StartInterval=60`, `RunAtLoad=true`, `LimitLoadToSessionType=Aqua` — GUI 로그인 세션에서만 동작).
- **스크립트**: `~/.aicompany/dispatcher-poller.sh` (사본: `ops/dispatcher-poller.sanitized.sh`, gist ID는 `<COMPANY_GIST_ID>` 플레이스홀더로 마스킹).
- **판정 로직**: 매 60초 gist를 ETag 조건부 GET(304면 비용 0, LLM 호출 없음). `requests[]` 중 `status=="new" && action != "company.refresh"`가 하나라도 있으면 헤드리스 `claude -p`를 기동해 `dispatch-inbox` 스킬을 1회 처리시킨다. 같은 new 집합이 3회 연속 무진전이면 30분 backoff(비용 폭주 차단). 실패 시 10분 backoff + ETag 삭제(다음 폴이 반드시 fresh GET으로 재시도하도록).
- **동시성 가드**: `$CO/.dispatch.lock`(다른 디스패처 레인이 작업 중이면 스킵), 폴러 자체 락(`~/.aicompany/state/poller.lock.d`, 스테일 45분).
- **헤드리스 실행 방식**: `PATH="$BASE/bin" claude -p "..." --dangerously-skip-permissions --setting-sources user --strict-mcp-config --model sonnet --max-budget-usd 2`
  - `PATH`를 안전 도구함(`~/.aicompany/bin`, 26개 명령만)으로 제한 — python·curl·node·ssh·bash·mv 등 위험 도구는 OS 레벨에서 아예 안 보임.
  - `--dangerously-skip-permissions`는 launchd(앱 밖)가 앱의 권한 검문소에 연결할 수 없어 Bash가 전면 차단되기 때문에 이 모드로만 실행 가능 — 안전은 [잠긴 PATH + 스킬 자체의 불가침 금지 목록] 두 겹이 담당한다.
  - `--setting-sources user`: CLI 2.1.207부터 사용자 스킬(`~/.claude/skills`) 로딩이 `user` 설정 소스에 묶임 — 과거 `--setting-sources ""`(무설정)로 돌리다 2026-07-11 자동 업데이트 직후 스킬이 안 보여 무인 레인 전체가 멈춘 회귀가 실측됨(15:56 정상→16:12 고장). 현재는 `user`로 수정 + 프롬프트에 "스킬 미발견 시 SKILL.md 파일 직접 읽기" 폴백을 추가해 향후 유사 회귀에도 내성을 갖게 함.
  - 타임아웃: 25분(1500초) 수동 워치독(`timeout(1)` 부재 대응) — TERM 후 10초 유예, 그래도 살아있으면 KILL.

### 레인 B — scheduled-tasks(Routine) 정기 회차 (하루 3회, 데스크톱 모드)
- **실체**: Claude Code/Cowork의 `scheduled-tasks` 기능(Routine). 로컬 파일: `~/.claude/scheduled-tasks/{nurisimac-dispatch-0400,nurisimac-dispatch-2300}/SKILL.md` — 04:00·23:00 KST에 발화. **18:00 회차도 동일 메커니즘**(`company-dispatcher` 태스크, description에 "정기18시" 명시).
- **동결 프롬프트**: 세 태스크 전부 본문이 "dispatch-inbox 스킬을 실행해 접수함을 1회 처리하라"뿐 — 절차의 단일 진실원은 스킬 자체(`~/.claude/skills/dispatch-inbox/SKILL.md`)이고, 변경은 항상 그 파일에서만 한다는 원칙을 프롬프트 안에 명시. 7개 태스크 전부의 사본(마스킹됨): `ops/scheduled-tasks.sanitized/`.
- **레인 A와의 차이**: 이 레인이 켜지면 스킬의 `0-bis` 단계가 "데스크톱 모드"로 판정(도구 목록에 `mcp__scheduled-tasks__update_scheduled_task`가 보이므로) — 헤드리스 레인에서 금지된 발화형 action(`research.batch`·`research.reports`·`dev.implement`)을 이 레인에서만 `exec-research`/`exec-dev` 태스크로 발화(fireAt=+2분)할 수 있다. 04시 회차는 추가로 "일일 자산 스캔"을 수행.
- **기타 예약 태스크**: `chief-secretary`(온디맨드 브리핑, company.brief로 발화), `exec-research`(연구 배치, Chrome 필요), `exec-dev`(개발 구현), `ops-optimizer`(매월 1일 토큰 비용 점검).

## 2. 액션 ID → 실행 스킬/명령 매핑표

| Action ID | 실행 방식 | 실행 주체 |
|---|---|---|
| `company.refresh` | 인라인 (dispatch-inbox §3) | 두 레인 공통 |
| `company.brief` | 발화 (fireAt=+2분) | `chief-secretary` 태스크 |
| `research.index` / `research.wiki` / `biz.launch` / `biz.research` / `dev.verify` | 인라인 (repo `AI Company/COMPANY.md` ①의 트리거 절차) | 두 레인 공통 |
| `research.batch` / `research.reports` | 발화 (fireAt=+2분) — **레인 B(데스크톱 모드)에서만 가능**, 레인 A(헤드리스)는 `queued` 처리 후 다음 정기 회차로 이관 | `exec-research` 태스크 |
| `dev.implement` | 발화(`when=="now"`→+2분, `when=="0500"`→다가오는 05:00) — 레인 B 전용, 레인 A는 큐잉 | `exec-dev` 태스크 |
| `ministry.scan` | 인라인 (dispatch-inbox §3-bis) | 두 레인 공통 — 사역팀 화이트리스트 |
| `ministry.board` | 인라인 (dispatch-inbox §3-ter) | 두 레인 공통 — 사역팀 화이트리스트, 기획 보드 대화 프로토콜 |
| `free`(자유 텍스트) | 안전 판정 후 인라인 실행 또는 `user` 보류 | 두 레인 공통 |
| 미등록 action | `user` 전환 | — |

`ministry.research`(P4-S4 대상)는 아직 스킬 절차가 없다 — 현재는 `free` 판정에 걸리지 않으면 미등록으로 `user` 처리된다.

## 3. worklog 기록 형식

`$CO/worklog/YYYY-MM.md`에 매 처리마다 1줄 append:
```
- [MM-DD HH:MM] [팀] action — 결과 — (디스패처|실행자|인세션)
```
Gist `worklog[]`(company-status.json 최상위)는 **최근 48시간분만**의 미러(표시용) — 전체 이력은 로컬 `worklog/*.md`에 영구 보존. `requests[]`는 `status=="done"` 24시간·`status=="user"` 14일 경과 시 gist에서만 제거(로컬 이력 무관).

## 4. 실패·재시도 정책

- **레인 A(launchd)**: 헤드리스 `claude -p` 실패(rc≠0) → ETag 캐시 삭제(다음 폴이 반드시 200으로 재조회) + 10분 backoff, 실패 카운트 누적. 같은 new 집합이 3회 연속 무진전이면 30분 backoff(별개 규칙, 무한 재시도 차단).
- **레인 B(scheduled-tasks)**: 재시도 로직 없음(정기 회차 자체가 다음 트리거를 재시도로 겸함) — 실패해도 다음 04/18/23 회차가 자동으로 재확인.
- **동시성**: `$CO/.dispatch.lock`(45분 스테일)·`$CO/.gist-push.lock`(5분 스테일)로 레인 A/B 및 수동 개입 간 경합 방지. Gist를 만지는 단계는 정기 회차 시간대(03:50~04:20, 17:50~18:20, 22:50~23:20 KST)를 피하는 것이 안전(R6).

## 5. 재구축 절차 (새 맥에서 엔진 재현)

1. `gh auth login`으로 GitHub CLI 인증(gist·repo 스코프).
2. `~/.aicompany/` 디렉터리 생성: `bin/`(안전 도구함 — 필요 명령만 심볼릭 링크, 예: `gh`·`jq`), `state/`, `dispatcher-poller.sh`(본 문서의 `ops/dispatcher-poller.sanitized.sh`에서 GIST ID를 실제 값으로 치환해 복사).
3. `~/Library/LaunchAgents/com.aicompany.dispatcher-poller.plist` 배치 후 `launchctl load` (경로는 `devices/<디바이스명>/` 프로파일 참조 — P1-S5 이후 생성).
4. `~/.claude/skills/dispatch-inbox/`에 비공개 컴패니언 repo(`ai-company-internal`, P1-S4 §5 판정 참조)의 `skills/dispatch-inbox/` 사본 배치.
5. Claude Code에서 scheduled-tasks(Routine) 3개(04:00/18:00/23:00 KST, 본문은 위 "동결 프롬프트" 그대로) 등록.
6. `AI Company/COMPANY.md`·`gist-config.md`를 Dropbox 동기화 폴더에서 확보(별도 백업 채널 — 이 repo 밖).
7. 검증: 접수함에 테스트 `free` 요청 1건 주입 → 60초 내 레인 A가 처리하는지 확인(대시보드 UI 또는 `docs/plan/02-master-plan.md` P5 시나리오 절차로만 — 수동 Gist 조작 금지, 레인 A와 경합 위험).
