# 00 — 문서 지도: AI 연구·사역·사업 자동화 시스템 계획

> 2026-07-12, 계획 세션 산출. 목적: 공학자의 "AI 연구 자동화 시스템 개발" 강의(캡처 24장)를 분석·이식해 기존 **AI Company 시스템**을 확장하고, 기존 빌드 전체를 감사·수리한다. **실행은 Sonnet 5 빌더 세션, 점검·오류 대응은 Opus 4.8 검수자 세션에 위임** — 이 폴더가 그 두 세션의 전체 입력이다.

## 읽기 순서 (소비자별)

| 누구 | 무엇을 읽나 |
|---|---|
| **사용자(Nuri)** | 이 파일 → `05`(감사 결과) → `01`(강의 분석 — §2 증거표를 원본과 대조 가능) → `02`(빌드 계획+§3 결정 대기 목록) → 빌더/검수 세션 기동은 `03`/`04`의 복붙 블록 |
| **Sonnet 5 빌더** | `03` 킥오프가 전부 안내(→ `02` 단계 → `06` 수리 명령 → `07`에 기록) |
| **Opus 4.8 검수자** | `04` 킥오프가 전부 안내(→ `02` 수용 기준 → `07` 증거 대조 → `08`에 판정) |

## 파일 목록

| 파일 | 역할 | 기록 권한 |
|---|---|---|
| `01-lecture-analysis.md` | 강의 24장 재배열(증거표·신뢰도)·아키텍처 추출·모방 결정표 | 고정(수정은 사용자 지시로만) |
| `02-master-plan.md` | 빌드 단계 P0~P6(수용 기준·디바이스 태그·게이트 G1~G3)·리스크 R1~R14·결정 대기 | 고정 |
| `03-kickoff-sonnet5.md` | 빌더 킥오프 복붙 블록(공통 A + iMac 부록 B) | 고정 |
| `04-kickoff-opus48.md` | 검수자 킥오프 복붙 블록(판정·게이트·플레이북) | 고정 |
| `05-audit-report.md` | 전체 감사: 발견 F-01~F-15 + 커버리지 맵(UNVERIFIED 정직 표기) | 고정 |
| `06-fix-commands.md` | 수정 명령문(FIX)·위임 검증(V)·정리 후보(승인 대기) | 고정 |
| `07-execution-ledger.md` | 실행 원장 — 상태의 단일 진실원, 세션 간 재개 지점 | **빌더만** |
| `08-inspection-log.md` | 검수 판정·게이트 결정·개입 기록 | **검수자만** |

## 환경 사실 요약 (실측 기준)

- **디바이스**: nurisimac(iMac) = 디스패처·로컬 파일·Obsidian·Chrome(NotebookLM)의 실행 지점. 원격(claude.ai/code) = repo·문서·원격 가능 빌드. 규약·스킬의 SSOT는 이 repo.
- **원격 세션 제약**: Gist 원문 403 / Dropbox 도구 승인 게이트 / 커스텀 스킬 본문 접근 불가 / Drive 읽기 가능 → `[IMAC-ONLY]` 태그와 큐(07 §3)로 처리.
- **지시 우선순위**: 안전 규칙(삭제 금지·백업·2회 실패 중단) > 위임 문서의 자율 실행 > 전역 "질문 후 진행" (P1-S1에서 정식화).
- **민감정보 규약**: Gist ID·토큰·개인정보는 이 폴더 문서에 쓰지 않는다 — "gist-config.md(Dropbox AI Company/) 참조"로 간접 표기. 매 push 전 시크릿 스캔.
- **현행 컨텍스트**: 사역지는 희성교회 청소년부(응암교회 자료는 前사역지 아카이브 — F-13). 제품: Hubrary, VoiceReading.

## 진행 체크리스트 (PR 본문과 동기)

- [x] 계획 산출(이 폴더 9개 문서) — 계획 세션
- [ ] G1: 기반 수리(P1) — 빌더+검수
- [ ] 기억 계층 LLM Wiki(P2)
- [ ] 절차·역할 계층(P3)
- [ ] Loop 배선(P4)
- [ ] G2: 3필러 종단 데모(P5)
- [ ] G3: 병합·운영 이행(P6) + 정리 후보 사용자 승인

## 지금 바로 시작하려면 (사용자)

1. 이 PR을 검토·병합(또는 브랜치 상태로 진행해도 됨 — 아래 명령에 브랜치 체크아웃 포함).
2. **iMac 빌더 (Claude Code CLI, 권장 선행)** — 터미널에서:
   ```bash
   git clone https://github.com/jtthw64-create/ai-company-dashboard.git ~/ai-company-dashboard  # 최초 1회
   cd ~/ai-company-dashboard && git checkout claude/ai-automation-system-plan-b3dzlo            # 병합 전일 때만
   git pull && claude --model claude-sonnet-5
   ```
   세션에 붙여넣기: `너는 빌더(Sonnet 5)다. docs/plan/03-kickoff-sonnet5.md의 블록 A와 B를 그대로 지시로 삼아 '첫 15분 프로토콜'부터 시작하라.`
3. **원격 빌더**: claude.ai/code 새 세션(repo 선택, 모델 Sonnet 5) → `03` 상단 ②의 한 줄 붙여넣기.
4. **검수**: 빌더가 "게이트 준비 완료"라고 하면 — iMac CLI `claude --model claude-opus-4-8` 또는 claude.ai/code 새 세션(Opus 4.8)에 붙여넣기: `너는 검수자(Opus 4.8)다. docs/plan/04-kickoff-opus48.md의 복붙 블록을 그대로 지시로 삼아 07의 최신 기록을 판정하라.`
5. `02` §3 결정 대기 6건은 편할 때 채팅/PR 코멘트로 답하면 됨.
