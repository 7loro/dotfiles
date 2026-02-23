# Gmail 초기 설정 가이드

accounts.yaml이 없거나 계정이 등록되지 않은 경우 이 가이드를 따른다.

## 1. Google Cloud 프로젝트 설정

### 1.1 프로젝트 생성

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 상단 프로젝트 선택기 → "새 프로젝트"
3. 프로젝트 이름 입력 (예: `gmail-skill`)
4. "만들기" 클릭

### 1.2 Gmail API 활성화

1. 왼쪽 메뉴 → "API 및 서비스" → "라이브러리"
2. "Gmail API" 검색
3. "사용" 버튼 클릭

### 1.3 OAuth 동의 화면 구성

1. "API 및 서비스" → "OAuth 동의 화면"
2. 사용자 유형: "외부" 선택 → "만들기"
3. 앱 정보 입력:
   - 앱 이름: `Gmail Skill`
   - 사용자 지원 이메일: 본인 이메일
   - 개발자 연락처: 본인 이메일
4. "저장 후 계속"
5. 범위 추가:
   - `https://www.googleapis.com/auth/gmail.modify`
   - `https://www.googleapis.com/auth/gmail.send`
   - `https://www.googleapis.com/auth/gmail.labels`
6. 테스트 사용자 추가 (본인 Gmail 주소)
7. "저장 후 계속"

### 1.4 OAuth 클라이언트 ID 생성

1. "API 및 서비스" → "사용자 인증 정보"
2. "사용자 인증 정보 만들기" → "OAuth 클라이언트 ID"
3. 애플리케이션 유형: **데스크톱 앱**
4. 이름: `Gmail Skill Client`
5. "만들기" 클릭
6. **JSON 다운로드** 클릭

### 1.5 credentials.json 저장

```bash
mv ~/Downloads/client_secret_*.json references/credentials.json
```

## 2. 계정 설정

### 2.1 accounts.yaml 생성

```bash
cp assets/accounts.default.yaml accounts.yaml
```

### 2.2 accounts.yaml 편집

```yaml
accounts:
  personal:
    email: your-personal@gmail.com
    description: 개인 Gmail
  work:
    email: your-work@company.com
    description: 업무용 계정
```

## 3. 계정 인증

### 3.1 의존성 설치

```bash
uv sync
```

### 3.2 각 계정 인증

```bash
# 개인 계정 인증
uv run python scripts/setup_auth.py --account personal

# 업무 계정 인증
uv run python scripts/setup_auth.py --account work
```

브라우저 열리면:
1. Google 계정 로그인
2. 권한 요청 승인
3. "확인되지 않은 앱" → "고급" → "계속"
4. 모든 권한 허용

### 3.3 인증 확인

```bash
uv run python scripts/setup_auth.py --list
```

## 4. 테스트

```bash
# 메일 목록 테스트
uv run python scripts/list_messages.py --account personal --max 5

# 프로필 확인
uv run python scripts/manage_labels.py --account personal profile
```

## 문제 해결

| 오류 | 해결 |
|------|------|
| credentials.json 없음 | 1.4-1.5 단계 확인. OAuth 클라이언트 ID JSON 다운로드 |
| 토큰 만료 | `uv run python scripts/setup_auth.py --account {name}` 재인증 |
| 확인되지 않은 앱 | OAuth 동의 화면에서 테스트 사용자 추가 |
| 권한 부족 | OAuth 동의 화면에서 필요한 범위 추가 |

## 파일 체크리스트

```
gmail-improved/
├── accounts.yaml              # 계정 정보
├── references/
│   └── credentials.json       # OAuth Client ID
└── accounts/
    ├── personal.json          # personal 토큰
    └── work.json              # work 토큰
```
