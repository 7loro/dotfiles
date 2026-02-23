"""Gmail API 공통 유틸리티 모듈.

인증, 설정 로드, 헬퍼 함수를 제공한다.
"""

import json
import os
import yaml
from datetime import datetime, timezone
from pathlib import Path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# 경로 상수
SKILL_DIR = Path(__file__).resolve().parent.parent
CREDENTIALS_FILE = SKILL_DIR / "references" / "credentials.json"
TOKENS_DIR = SKILL_DIR / "accounts"


def _get_credentials_file() -> str:
    """credentials.json 경로를 반환한다.

    파일이 없으면 환경변수(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET)로
    임시 credentials.json을 생성한다.
    """
    if CREDENTIALS_FILE.exists():
        return str(CREDENTIALS_FILE)

    client_id = os.environ.get("GOOGLE_CLIENT_ID", "")
    client_secret = os.environ.get("GOOGLE_CLIENT_SECRET", "")
    if client_id and client_secret:
        data = {
            "installed": {
                "client_id": client_id,
                "client_secret": client_secret,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "redirect_uris": ["http://localhost"],
            }
        }
        CREDENTIALS_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(CREDENTIALS_FILE, "w") as f:
            json.dump(data, f)
        return str(CREDENTIALS_FILE)

    raise FileNotFoundError(
        f"credentials.json이 없습니다: {CREDENTIALS_FILE}\n"
        "GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET 환경변수를 설정하거나\n"
        "Google Cloud Console에서 OAuth 클라이언트 ID JSON을 다운로드하세요."
    )

# Gmail API 스코프
SCOPES = [
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.labels",
]


def load_config() -> dict:
    """accounts.yaml에서 계정 정보를 로드한다.

    루트 디렉토리를 먼저 확인하고, 없으면 assets/ 디렉토리를 확인한다.
    """
    for path in [SKILL_DIR / "accounts.yaml", SKILL_DIR / "assets" / "accounts.yaml"]:
        if path.exists():
            with open(path) as f:
                return yaml.safe_load(f)
    raise FileNotFoundError(
        "accounts.yaml이 없습니다.\n"
        "  cp assets/accounts.default.yaml accounts.yaml\n"
        "  # 계정 정보 편집 후\n"
        "  uv run python scripts/setup_auth.py --account <name>"
    )


def get_account_email(account_name: str) -> str:
    """계정 이름으로 이메일 주소를 조회한다."""
    config = load_config()
    accounts = config.get("accounts", {})
    if account_name not in accounts:
        available = ", ".join(accounts.keys())
        raise ValueError(f"계정 '{account_name}'을 찾을 수 없습니다. 사용 가능: {available}")
    return accounts[account_name]["email"]


def get_credentials(account_name: str) -> Credentials | None:
    """저장된 토큰에서 OAuth 자격증명을 로드한다.

    토큰이 만료되었으면 자동 갱신을 시도한다.
    토큰이 없거나 유효하지 않으면 None을 반환한다.
    """
    # 계정 존재 확인
    get_account_email(account_name)

    token_path = TOKENS_DIR / f"{account_name}.json"
    creds = None

    if token_path.exists():
        creds = Credentials.from_authorized_user_file(str(token_path), SCOPES)

    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
        # 갱신된 토큰 저장
        token_path.parent.mkdir(parents=True, exist_ok=True)
        with open(token_path, "w") as f:
            f.write(creds.to_json())

    if not creds or not creds.valid:
        return None

    return creds


def authenticate(account_name: str) -> Credentials:
    """OAuth 인증 플로우를 실행하고 토큰을 저장한다."""
    get_account_email(account_name)

    creds_file = _get_credentials_file()
    flow = InstalledAppFlow.from_client_secrets_file(creds_file, SCOPES)
    creds = flow.run_local_server(port=0)

    # 토큰 저장
    token_path = TOKENS_DIR / f"{account_name}.json"
    token_path.parent.mkdir(parents=True, exist_ok=True)
    with open(token_path, "w") as f:
        f.write(creds.to_json())

    return creds


def get_gmail_service(account_name: str):
    """인증된 Gmail API 서비스 객체를 반환한다."""
    creds = get_credentials(account_name)
    if creds is None:
        raise RuntimeError(
            f"계정 '{account_name}'이 인증되지 않았습니다.\n"
            f"먼저 실행: uv run python scripts/setup_auth.py --account {account_name}"
        )
    return build("gmail", "v1", credentials=creds)


def format_date(timestamp_ms: str | int) -> str:
    """밀리초 타임스탬프를 읽기 좋은 날짜 문자열로 변환한다."""
    dt = datetime.fromtimestamp(int(timestamp_ms) / 1000, tz=timezone.utc)
    return dt.strftime("%Y-%m-%d %H:%M")


def get_header(headers: list[dict], name: str) -> str:
    """메일 헤더 목록에서 특정 필드 값을 추출한다."""
    for h in headers:
        if h["name"].lower() == name.lower():
            return h["value"]
    return ""


def decode_body(payload: dict) -> str:
    """메일 페이로드에서 본문 텍스트를 추출한다.

    multipart 메일의 경우 재귀적으로 파싱한다.
    """
    import base64

    body = ""

    if payload.get("body", {}).get("data"):
        body = base64.urlsafe_b64decode(payload["body"]["data"]).decode("utf-8", errors="replace")
    elif payload.get("parts"):
        # text/plain을 우선, 없으면 text/html
        plain_parts = []
        html_parts = []
        for part in payload["parts"]:
            mime = part.get("mimeType", "")
            if mime == "text/plain":
                plain_parts.append(part)
            elif mime == "text/html":
                html_parts.append(part)
            elif mime.startswith("multipart/"):
                # 재귀적으로 파싱
                nested = decode_body(part)
                if nested:
                    plain_parts.append({"body": {"data": None}, "_decoded": nested})

        target_parts = plain_parts or html_parts
        for part in target_parts:
            if "_decoded" in part:
                body += part["_decoded"]
            elif part.get("body", {}).get("data"):
                body += base64.urlsafe_b64decode(part["body"]["data"]).decode("utf-8", errors="replace")

    return body
