# 07 — 실행 원장 (빌더 전용 기록)

> **기록자: Sonnet 5 빌더 세션만.** 검수자·사용자는 읽기만. 다른 계획 문서(00~06, 08)는 빌더도 수정 금지(제안은 아래 §5에).
> 세션이 바뀌어도 이 파일이 상태의 단일 진실원이다 — 새 빌더 세션은 여기서부터 재개한다.

## 1. 능력 프로브 기록

| 일시(KST) | 세션 환경 | git 브랜치 | 실행 가능 태그 | 프로브 출력 요약 |
|---|---|---|---|---|
| 2026-07-12 12:58 | iMac Claude Code CLI (nurisimac, Sonnet 5) | claude/ai-automation-system-plan-b3dzlo | [ANY] (IMAC-ONLY 포함) | date=2026-07-12 12:58:51 KST · gh auth status=✓ jtthw64-create(gist,read:org,repo,workflow) · ls ~/.claude/skills=8개(dispatch-inbox·find-skills·frontend-design·notebooklm·notebooklm-reports-code·research-index·web-design-guidelines·wiki-note) · Dropbox 읽기=승인 없이 즉시 성공(로컬 CLI라 마운트 직접 접근) · Google Drive 읽기=성공(로컬 마운트) · launchctl: `com.aicompany.dispatcher-poller` 활성 확인(운영 중 — 접수함 수동 조작 시 경합 주의) · crontab -l=비어있음 |
| 2026-07-12 13:00 (UTC 04:00 기준 환산) | 원격(claude.ai/code), Sonnet 5 빌더 | `claude/ai-automation-system-plan-b3dzlo` | `[REMOTE-OK]`+`[ANY]` 가능, `[IMAC-ONLY]`/`[USER]` 불가 | `git remote -v`=origin 정상, `git branch --show-current`=위 브랜치, `date`=2026-07-12T04:00 UTC. GitHub MCP `get_me`=성공(login jtthw64-create). Google Drive `list_recent_files`=성공(승인 필요 없이 통과, "Claude Cowork GD" 폴더 확인). Dropbox `who_am_i`=성공(승인 프롬프트 없이 통과 — 05 감사 당시와 달리 이번 세션은 사전 승인된 상태로 보임). Gist raw fetch(`curl api.github.com/gists/<ministry-room.html DEFAULT_GIST_ID>`)=403(예상대로). `ls ~/.claude/skills`=`session-start-hook` 1건만 존재(로컬 12종 스킬은 이 원격 환경에 없음 — iMac 전용 확인 필요, FIX-15 대상). |

## 2. 단계 진행 표

상태: `todo`(기본) / `doing` / `done` / `blocked-handoff`(다른 환경 큐로) / `failed`(2회 실패 — 중단·보고)

| 단계 ID | 상태 | 커밋 SHA | 증거 (명령 출력·파일 경로·스크린샷 설명 붙여넣기) | 일시(KST) |
|---|---|---|---|---|
| P0-S1 | done | 6ec188a | 위 능력 프로브 표 참조(iMac·원격 양쪽 기록) | 2026-07-12 12:58 |
| P1-S1 | done | 6ec188a | iMac 빌더가 전역 CLAUDE.md(Cowork GD)에 FIX-07 "지시 우선순위" 섹션 반영(백업 `CLAUDE.md.bak-20260712`) — Cowork·repo 양측 완료. 원격 세션에서 별도로 repo CLAUDE.md를 작성했던 시도(구 커밋)는 iMac의 6ec188a와 중복되어 리베이스 시 폐기함(§5 판정 참조). | 2026-07-12 |
| P1-S2 | done | 6ec188a, a16b0a6 | repo `CLAUDE.md` 신설 — 7요소(시스템 지도/표준 용어/타임스탬프 규약/안전 보류 기준/화이트리스트 매핑표(TBD 표기)/현행 컨텍스트/민감정보 규칙) 전부 포함(iMac 빌더 작성). ★추가 수정(a16b0a6): 공개 repo 민감정보 우려로 "현행 컨텍스트"의 구체적 교회명·소속을 "사역"으로 일반화(자동 모드 분류기 지적 + 사용자 확인 반영). | 2026-07-12 |
| P1-S3 | done | (다음 커밋) | `docs/ops/ENGINE.md` 신설(엔진 2레인 구성·액션매핑표·worklog형식·재시도정책·재구축절차) + V-01 실측(launchd 나노폴러+scheduled-tasks 정기3회) + 상주 지시문 사본 `ops/`(마스킹 검증됨, 시크릿·gist ID 잔존 0건 확인). repo CLAUDE.md §5 매핑표 TBD도 이 문서 참조로 갱신. iMac 큐(§3)의 미소화 항목 소화 완료로 표기. | 2026-07-12 13:08 |
| P1-S4 | done | (별도 repo — 아래 참조) | ★계획 변경(사용자 확인, 아래 §5 판정): 스킬 원본 17종(활성 8+백업 9)을 이 공개 repo가 아니라 신설 **비공개 컴패니언 repo**(`jtthw64-create/ai-company-internal`)에 커밋(FIX-15 목적은 그대로 달성 — 버전관리 편입, 단 SSOT 위치 변경). description 필드 대조: 불일치 0건. `report-grading` 폴더(Dropbox skills_export 내)는 SKILL.md 없이 빈 `refs/`만 존재 — 스킬 아님, 미편입(§6 정리 후보 참조). 미발견 스킬 없음(로컬+Dropbox 탐색으로 전량 확보). | 2026-07-12 |
| P1-S5 | todo | | | |
| P1-S6 | todo | | | |
| P1-S7 | todo | | | |
| P2-S1 | blocked-handoff | | Obsidian 볼트가 iMac에만 있어 원격에서 폴더 스캐폴드 생성 불가 — §3 iMac 큐에 적재(구조: authors/works/topics/passages/venues/years+index.md+log.md). | 2026-07-12 |
| P2-S2 | done | d852d53 | `wiki-templates/`에 템플릿 3종(요약/비판적 읽기/Literature Matrix) + 각 샘플 1건 repo 커밋. 볼트 사본 배치는 P2-S1 선행이라 iMac 큐로 이관(§3). | 2026-07-12 |
| P2-S3 | todo | | | |
| P2-S4 | todo | | | |
| P3-S1 | blocked-handoff | | 소급 점검표 작성에는 실제 스킬 12종 원본이 필요(P1-S4 선행, `[IMAC-ONLY]`) — 원격에는 `session-start-hook` 1건만 존재. P1-S4 완료 후 재개. | 2026-07-12 |
| P3-S2 | todo | | | |
| P3-S3 | done | dace39d | `roles/`(README·company-team.md·church-ministry.md) — 회사 5역할(개발·연구·사업·비서·디스패처총괄), 교회 6역할(목회자·부장·총무·디자인·찬양팀·리스크관리자) 책임/금지사항/충돌방지 명세. church-orchestration 스킬과의 1줄 연결은 P1-S4(스킬 원본 편입) 이후로 보류(스킬 파일이 아직 repo에 없음). | 2026-07-12 |
| P3-S4 | blocked-handoff | | 선행 P2(Wiki 볼트, IMAC-ONLY) 미완 — 착수 보류. | 2026-07-12 |
| P3-S5 | todo | | | |
| P4-S1 | done | d1d0fec | `skills/sermon-loop/SKILL.md` — 본문 확정→초안→리뷰(3항목 체크리스트)→수정→재검토 4단계 + 시편 23편 예시 1사이클(형식 시연용, 실제 원고 아님). 저장 경로는 FIX-09 확정 전 임시 경로로 표기. | 2026-07-12 |
| P4-S2 | blocked-handoff | | 선행 P3-S4(Writing Reviewer 서브에이전트) 미완 — 착수 보류. | 2026-07-12 |
| P4-S3 | blocked-handoff | | 선행 P1-S3(ENGINE.md, IMAC-ONLY) 미완 — 착수 보류. | 2026-07-12 |
| P4-S4 | todo | | | |
| P4-S5 | todo(결정 대기) | | | |
| P5-S1 | todo | | | |
| P5-S2 | todo | | | |
| P5-S3 | todo | | | |
| P6-S1 | todo | | | |
| P6-S2 | todo | | | |
| P6-S3 | todo | | | |

## 3. iMac 작업 큐 (원격 빌더가 적재 → iMac 빌더가 소화)

| 적재일 | 단계 ID | 한 줄 지시 | 소화 여부 |
|---|---|---|---|
| 2026-07-12 | P1-S3 | V-01(엔진 실물 확인: launchctl/crontab/ps 출력 + 상주 세션 지시문 사본) 실행 후 `docs/ops/ENGINE.md` 작성 | 소화됨(§2 P1-S3 참조) |
| 2026-07-12 | P1-S4 | `~/.claude/skills/`, Dropbox, Cowork 작업폴더에서 스킬 12종 원본 탐색·수집 → repo `skills/`에 복사(이동 아님), claude.ai 설명문과 diff 확인 | 소화됨(§2 P1-S4 참조 — 단 대상 repo는 `ai-company-internal`로 변경) |
| 2026-07-12 | P2-S1 | Obsidian "LLM WIKI" 볼트에 `authors/works/topics/passages/venues/years/+index.md+log.md` 스캐폴드 생성, `wiki-templates/`(P2-S2, 원격에서 완료됨) 사본을 볼트에 배치 | 미소화 |
| 2026-07-12 | P3-S1 | P1-S4로 스킬 원본 확보 후 `skills/QUALITY-CHECKLIST.md` 제정 + 12종+α 소급 점검표 작성 | 미소화(P1-S4 선행) |

## 4. 원격 작업 큐 (iMac 빌더가 적재 → 원격 빌더가 소화)

| 적재일 | 단계 ID | 한 줄 지시 | 소화 여부 |
|---|---|---|---|

## 5. 판정 기록·제안 (모호했던 선택, 02에 없는 필요 작업 제안)

| 일시 | 유형(판정/제안) | 내용과 사유 |
|---|---|---|
| 2026-07-12 | 판정 | 원격 세션에서 Google Drive·Dropbox 도구 호출이 승인 프롬프트 없이 통과함(05 감사 당시 "Dropbox 도구=호출마다 승인 필요" 기록과 다름) — 세션/환경 설정 차이로 추정, 보수적으로 "이번 세션 한정 결과"로만 기록하고 05의 일반화된 제약 서술은 수정하지 않음(00~06 수정 금지 원칙). |
| 2026-07-12 | 판정 | P4-S1(sermon-loop) 실행 시 P3-S4(Writing Reviewer 서브에이전트)가 아직 없어, 스킬 안에 리뷰 체크리스트를 임시 내장하고 "P3-S4 완료 시 그 스킬 호출로 교체" 주석을 남기는 보수적 기본값을 택함(02가 P4-S1에 명시적 선행 조건을 걸지 않았으므로 진행 가능하다고 판단). |
| 2026-07-12 | 판정 | push 시 iMac 빌더가 이미 P1-S1/S2(FIX-06/07)를 완료·push한 것을 발견(fetch first 충돌) — rebase로 통합하면서 원격 세션이 독자 작성했던 repo CLAUDE.md 커밋은 iMac판(6ec188a)과 내용이 동형이라 폐기하고 iMac판을 채택함(중복 작업 방지, R14 원칙 적용). |
| 2026-07-12 | 제안 | P2-S2 수용 기준("템플릿 3파일 repo 커밋 + 샘플")이 볼트 배치를 요구하지 않아 원격에서 완료 가능했음 — 02의 P2-S2 문구에 "(repo 커밋은 원격 가능, 볼트 배치는 P2-S1 선행 후 iMac)"을 명시적으로 추가하면 향후 태그 판단이 더 빨라질 것으로 제안(02는 빌더가 직접 수정하지 않음 — 검수자/사용자 검토용 제안으로만 기록). |
| 2026-07-12 | 판정(★계획 변경, 사용자 승인) | P1-S4(FIX-15) 실행 중 자동 모드 분류기가 "개인 워크플로우가 담긴 스킬 전체를 공개 repo에 커밋"을 반복 차단(P1-S2의 교회명 노출 지적과 동일 계열). 사용자에게 상황 보고 후 **SSOT 위치를 이 공개 repo에서 신설 비공개 컴패니언 repo(`jtthw64-create/ai-company-internal`)로 변경**하는 것으로 사용자 승인받아 진행. 근거: 이 공개 repo의 원래 범위는 대시보드 3장의 GitHub Pages 호스팅뿐(README 원문)이었고, 스킬 원본·역할 명세 등 실제 운영 자료는 그 범위를 벗어남. GitHub Pages는 무료 플랜에서 private repo 미지원이라 대시보드는 계속 이 공개 repo에 유지. **02·06 문서가 "repo skills/"로 지칭한 곳은 이후 전부 `ai-company-internal`로 해석**(00~06은 빌더가 직접 수정하지 않으므로 이 판정 기록이 정정 근거). 이미 이 공개 repo에 커밋된 `roles/`(P3-S3, 원격 세션 작성)·`ops/`(P1-S3, 본 세션 작성)의 재이전 여부는 **미결정 — 삭제·이동은 사용자 별도 승인 필요**(안전 규칙, 기존 발행 커밋 삭제 금지 원칙), §6에 정리 후보로 등재. |

## 6. 정리 후보 추가분 (06 §C에 더해 빌드 중 발견된 것 — 실행 금지, 기록만)

| 항목 | 사유 |
|---|---|
| Dropbox `Claude Dropbox/skills_export/report-grading/` | SKILL.md 없이 빈 `refs/` 폴더만 존재 — 완성된 스킬이 아님. 미편입(FIX-15 대상에서 제외). 사용자가 용도를 기억하면 복구, 아니면 폐기 후보 |
| 공개 repo(`ai-company-dashboard`)의 `roles/`(P3-S3)·`ops/`(P1-S3) | P1-S4 판정 변경(위 §5)으로 신설된 비공개 `ai-company-internal`로 이전하는 게 일관되나, 이미 공개 커밋·push된 상태라 삭제는 사용자 승인 없이 진행 불가. 내용 자체는 검토 결과 민감정보(gist ID·개인 실명 등) 없음 확인됨 — 유지해도 안전하지만, 일관성 위해 사용자가 원하면 이전+공개본 삭제(git revert) 가능 |
