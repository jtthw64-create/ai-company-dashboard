# roles/ — Subagent 역할 명세

> `docs/plan/02-master-plan.md` P3-S3. 강의 STEP 3의 "역할별 책임·금지사항" 아이디어를, 기존에 이미 대시보드 코드와 church-orchestration이 정의해 둔 역할 위에 명문화한다. 새 역할을 만드는 문서가 아니라 **기존 역할의 계약을 문서화**하는 문서다.

- `company-team.md` — 팀 회의실 5역할(연구·개발·사업·비서 + 상위 총괄). 출처: `team-room.html`(dev/research/business 팀), `index.html`(secretary 액션).
- `church-ministry.md` — 사역팀(교회) 6역할. 출처: `ministry-room.html`의 `PHASES` 배열(pastor/director/secretary/design/worship/risk).
- 각 역할 항목은 **책임(무엇을 산출하는가) · 금지사항(하지 않는 것) · 충돌 방지 규칙(다른 역할과 겹칠 때 우선순위)** 3항목으로 통일한다.
- 이 명세는 아직 실행 스킬(church-orchestration 등) 코드를 바꾸지 않는다 — 연결은 스킬 쪽에서 이 파일을 참조하는 1줄 추가로 이루어진다(스킬 원본이 `skills/`에 편입된 뒤, P1-S4 선행).
