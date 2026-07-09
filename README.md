# AI Company 상황판

개인용 팀 오케스트레이션 상황판. GitHub Pages로 서빙되고, 데이터는 소유자의 secret gist(`company-status.json`)에서 60초 폴링으로 읽는다.

- 설정: 화면의 [동기화 설정]에 gist 권한 PAT + gist ID 입력 — localStorage에만 저장되며 repo/gist에 절대 기록하지 않는다.
- 이 repo에는 코드만 있다. 상태 데이터·운영 문서는 소유자의 비공개 저장소에서 관리된다.
