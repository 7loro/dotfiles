# Google Calendar 초기 설정 가이드

## 1. Google Cloud 프로젝트 설정

### 1.1 프로젝트 생성

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 상단 프로젝트 선택기 → "새 프로젝트"
3. 프로젝트 이름 입력 (예: `calendar-skill`)
4. "만들기" 클릭

### 1.2 Calendar API 활성화

1. 왼쪽 메뉴 → "API 및 서비스" → "라이브러리"
2. "Google Calendar API" 검색
3. "사용" 버튼 클릭

### 1.3 OAuth 동의 화면 구성

1. "API 및 서비스" → "OAuth 동의 화면"
2. 사용자 유형: "외부" 선택 → "만들기"
3. 앱 정보 입력:
   - 앱 이름: `Calendar Skill`
   - 사용자 지원 이메일: 본인 이메일
   - 개발자 연락처: 본인 이메일
4. "저장 후 계속"
5. 범위 추가:
   - `https://www.googleapis.com/auth/calendar`
   - `https://www.googleapis.com/auth/calendar.events`
6. 테스트 사용자 추가 (본인 Gmail 주소)

### 1.4 OAuth 클라이언트 ID 생성

1. "API 및 서비스" → "사용자 인증 정보"
2. "사용자 인증 정보 만들기" → "OAuth 클라이언트 ID"
3. 애플리케이션 유형: **데스크톱 앱**
4. 이름: `Calendar Skill Client`
5. "만들기" → **JSON 다운로드**

### 1.5 credentials.json 저장

```bash
mv ~/Downloads/client_secret_*.json references/credentials.json
```

## 2. 계정 인증 (최초 1회)

```bash
# 업무 계정
uv run python scripts/setup_auth.py --account work

# 개인 계정
uv run python scripts/setup_auth.py --account personal
```

브라우저에서 Google 로그인 → refresh token이 `accounts/{name}.json`에 저장됨.

## 3. 테스트

```bash
# 이벤트 조회 테스트
uv run python scripts/fetch_events.py --account work --days 3
```

## 문제 해결

| 오류 | 해결 |
|------|------|
| credentials.json 없음 | 1.4-1.5 단계 확인 |
| 토큰 만료 | `setup_auth.py --account {name}` 재인증 |
| 확인되지 않은 앱 | OAuth 동의 화면에서 테스트 사용자 추가 |
| 권한 부족 | calendar, calendar.events 범위 추가 |

## 파일 구조

```
google-calendar-improved/
├── SKILL.md
├── scripts/
│   ├── calendar_client.py      # API 클라이언트
│   ├── setup_auth.py           # 인증 설정
│   ├── fetch_events.py         # 이벤트 조회
│   └── manage_events.py        # 이벤트 관리
├── references/
│   ├── setup-guide.md          # 이 파일
│   └── credentials.json        # OAuth Client ID (gitignore)
└── accounts/                   # 계정별 토큰 (gitignore)
    ├── work.json
    └── personal.json
```
