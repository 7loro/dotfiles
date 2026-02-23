# Backlog API Configuration

## 설정 파일

실제 인증 정보는 스킬 루트의 `config.json`에 저장한다.

**경로**: `config.json` (SKILL.md와 같은 디렉토리)

```json
{
  "spaceKey": "YOUR_SPACE_KEY",
  "apiKey": "YOUR_API_KEY",
  "domain": "backlog.com",
  "projectKey": "YOUR_PROJECT_KEY"
}
```

## 필드 설명

| Key | Description | Example |
|-----|-------------|---------|
| spaceKey | Backlog 스페이스 식별자 | `mycompany` |
| apiKey | API 인증 키 (Backlog 개인설정에서 발급) | `abc123def456...` |
| domain | `backlog.com` 또는 `backlog.jp` (일본 리전) | `backlog.com` |
| projectKey | 기본 프로젝트 키 | `MYPROJ` |

## 사용법

Base URL: `https://{spaceKey}.{domain}/api/v2`

```
https://mycompany.backlog.com/api/v2/issues?apiKey=abc123def456
```

## 설정 확인 절차

1. `config.json`을 읽는다
2. `spaceKey`가 `YOUR_SPACE_KEY`이면 → 사용자에게 설정 입력 요청
3. 값이 설정되어 있으면 → API 호출에 사용
