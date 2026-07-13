# CLAUDE.md — ai-company-dashboard (공개 repo)

이 repo는 **GitHub Pages 대시보드 3장(index.html, team-room.html, ministry-room.html)의 호스팅 전용**이다. 여기에는 코드만 커밋한다 — 계획·스킬·역할·엔진 명세·원장 등 운영 문서는 소유자의 **비공개 컴패니언 repo**에서 관리한다(위치는 Dropbox의 `AI Company/gist-config.md` 참조). 운영 맥락이 담긴 파일을 이 repo에 커밋하지 말 것.

## 대시보드 코드 작업 규약

- **타임스탬프**: 저장은 KST `+09:00` 오프셋 ISO, 비교·정렬은 반드시 epoch 환산(`tms()` 패턴). ISO 문자열 직접 비교 금지 — 과거 Gist 기록에 UTC(`Z`)가 혼재한다.
- **표준 용어**: 실행 엔진은 "디스패처(로컬 폴러)" — 오케스트레이터·폴러 등 기존 표현은 동의어다.
- **안전 보류**: 커밋·금전·삭제·외부 발송은 자동 실행 금지 — 접수함에서 "사용자 실행" 보류+사유 표기(기존 관례 유지).
- **민감정보**: 토큰·개인정보·신규 Gist ID를 커밋하지 않는다(기존 하드코딩된 Gist ID는 무백엔드 설계상 유지 — 인증 토큰은 사용자 브라우저 localStorage에만 존재). push 전 시크릿 스캔: `grep -rInE '(ghp|github_pat)_[A-Za-z0-9]{8,}' .`
- **수정 절차**: 기존 HTML 수정 전 `.bak` 백업, 수정 후 로컬 미리보기로 렌더 확인. 같은 파일 수정 2회 연속 실패 시 중단·보고.
