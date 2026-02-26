"""Google Calendar API 공통 유틸리티 모듈.

인증, 설정 로드, 헬퍼 함수를 제공한다.
"""

import json
import os
import yaml
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

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

    파일이 없으면 환경변수(CLAUDE_SKILL_GOOGLE_CLIENT_ID, CLAUDE_SKILL_GOOGLE_CLIENT_SECRET)로
    임시 credentials.json을 생성한다.
    """
    if CREDENTIALS_FILE.exists():
        return str(CREDENTIALS_FILE)

    client_id = os.environ.get("CLAUDE_SKILL_GOOGLE_CLIENT_ID", "")
    client_secret = os.environ.get("CLAUDE_SKILL_GOOGLE_CLIENT_SECRET", "")
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
        "CLAUDE_SKILL_GOOGLE_CLIENT_ID / CLAUDE_SKILL_GOOGLE_CLIENT_SECRET 환경변수를 설정하거나\n"
        "Google Cloud Console에서 OAuth 클라이언트 ID JSON을 다운로드하세요."
    )

# Calendar API 스코프
SCOPES = [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/calendar.events",
]

# 기본 타임존
DEFAULT_TIMEZONE = "Asia/Seoul"


def load_config() -> dict:
    """accounts.yaml에서 계정 정보를 로드한다."""
    for path in [SKILL_DIR / "accounts.yaml", SKILL_DIR / "assets" / "accounts.yaml"]:
        if path.exists():
            with open(path) as f:
                return yaml.safe_load(f)
    raise FileNotFoundError(
        "accounts.yaml이 없습니다.\n"
        "  계정 정보를 작성한 후:\n"
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
    get_account_email(account_name)

    token_path = TOKENS_DIR / f"{account_name}.json"
    creds = None

    if token_path.exists():
        creds = Credentials.from_authorized_user_file(str(token_path), SCOPES)

    if creds and creds.expired and creds.refresh_token:
        try:
            creds.refresh(Request())
            token_path.parent.mkdir(parents=True, exist_ok=True)
            with open(token_path, "w") as f:
                f.write(creds.to_json())
        except Exception:
            # refresh token이 revoke된 경우 → 재인증 필요
            creds = None

    if not creds or not creds.valid:
        return None

    return creds


def authenticate(account_name: str) -> Credentials:
    """OAuth 인증 플로우를 실행하고 토큰을 저장한다."""
    get_account_email(account_name)

    creds_file = _get_credentials_file()
    flow = InstalledAppFlow.from_client_secrets_file(creds_file, SCOPES)
    creds = flow.run_local_server(port=0)

    token_path = TOKENS_DIR / f"{account_name}.json"
    token_path.parent.mkdir(parents=True, exist_ok=True)
    with open(token_path, "w") as f:
        f.write(creds.to_json())

    return creds


def get_calendar_service(account_name: str):
    """인증된 Calendar API 서비스 객체를 반환한다."""
    creds = get_credentials(account_name)
    if creds is None:
        raise RuntimeError(
            f"계정 '{account_name}'이 인증되지 않았습니다.\n"
            f"먼저 실행: uv run python scripts/setup_auth.py --account {account_name}"
        )
    return build("calendar", "v3", credentials=creds)


def parse_datetime(dt_str: str, tz: str = DEFAULT_TIMEZONE) -> tuple[str, bool]:
    """날짜/시간 문자열을 파싱하여 (ISO 문자열, 종일여부) 튜플을 반환한다.

    - '2026-01-06' → 종일 이벤트 (date 형식)
    - '2026-01-06T14:00:00' → 시간 지정 이벤트 (dateTime 형식, 타임존 적용)
    """
    # 종일 이벤트: YYYY-MM-DD (10자)
    if len(dt_str) == 10 and dt_str.count("-") == 2:
        datetime.strptime(dt_str, "%Y-%m-%d")  # 유효성 검증
        return dt_str, True

    # 시간 지정 이벤트
    dt = datetime.fromisoformat(dt_str)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=ZoneInfo(tz))
    return dt.isoformat(), False


def build_event_body(
    summary: str,
    start: str,
    end: str,
    timezone: str = DEFAULT_TIMEZONE,
    description: str | None = None,
    location: str | None = None,
    attendees: list[str] | None = None,
) -> dict:
    """Calendar API 이벤트 바디를 생성한다."""
    start_iso, is_allday = parse_datetime(start, timezone)
    end_iso, _ = parse_datetime(end, timezone)

    event = {"summary": summary}

    if is_allday:
        event["start"] = {"date": start_iso}
        event["end"] = {"date": end_iso}
    else:
        event["start"] = {"dateTime": start_iso, "timeZone": timezone}
        event["end"] = {"dateTime": end_iso, "timeZone": timezone}

    if description:
        event["description"] = description
    if location:
        event["location"] = location
    if attendees:
        event["attendees"] = [{"email": email.strip()} for email in attendees]

    return event


def format_event_time(event: dict) -> tuple[str, str]:
    """이벤트에서 시작/종료 시간을 읽기 좋은 문자열로 반환한다.

    Returns:
        (시작시간, 종료시간) 튜플. 종일 이벤트는 날짜만, 시간 이벤트는 HH:MM 형식.
    """
    start = event.get("start", {})
    end = event.get("end", {})

    if "date" in start:
        return start["date"], end.get("date", "")

    start_dt = datetime.fromisoformat(start.get("dateTime", ""))
    end_dt = datetime.fromisoformat(end.get("dateTime", ""))
    return start_dt.strftime("%H:%M"), end_dt.strftime("%H:%M")


def get_event_sort_key(event: dict) -> str:
    """이벤트를 시간순 정렬하기 위한 키를 반환한다.

    종일 이벤트는 해당 날짜의 00:00으로 취급한다.
    """
    start = event.get("start", {})
    if "dateTime" in start:
        return start["dateTime"]
    return start.get("date", "") + "T00:00:00"
