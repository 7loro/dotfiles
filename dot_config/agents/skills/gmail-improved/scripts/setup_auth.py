"""Gmail OAuth 인증 설정 스크립트.

사용법:
    uv run python scripts/setup_auth.py --account personal
    uv run python scripts/setup_auth.py --list
"""

import argparse
import sys
from pathlib import Path

# 스크립트 디렉토리를 path에 추가
sys.path.insert(0, str(Path(__file__).resolve().parent))

from gmail_utils import (
    TOKENS_DIR,
    authenticate,
    get_account_email,
    get_credentials,
    load_config,
)


def main():
    parser = argparse.ArgumentParser(description="Gmail OAuth 인증 설정")
    parser.add_argument("--account", help="인증할 계정 이름")
    parser.add_argument("--list", action="store_true", help="인증된 계정 목록 표시")
    args = parser.parse_args()

    if args.list:
        list_accounts()
        return

    if not args.account:
        parser.error("--account 또는 --list를 지정해주세요.")

    setup_account(args.account)


def list_accounts():
    """등록된 계정과 인증 상태를 표시한다."""
    try:
        config = load_config()
    except FileNotFoundError as e:
        print(f"오류: {e}")
        sys.exit(1)

    accounts = config.get("accounts", {})
    if not accounts:
        print("등록된 계정이 없습니다.")
        return

    print("=== Gmail 계정 목록 ===\n")
    for name, info in accounts.items():
        email = info.get("email", "?")
        desc = info.get("description", "")
        token_path = TOKENS_DIR / f"{name}.json"

        # 인증 상태 확인
        if token_path.exists():
            creds = get_credentials(name)
            status = "✅ 인증됨" if creds else "⚠️ 토큰 만료 (재인증 필요)"
        else:
            status = "❌ 미인증"

        print(f"  {name}:")
        print(f"    이메일: {email}")
        print(f"    설명: {desc}")
        print(f"    상태: {status}")
        print()


def setup_account(account_name: str):
    """특정 계정의 OAuth 인증을 수행한다."""
    try:
        email = get_account_email(account_name)
    except (FileNotFoundError, ValueError) as e:
        print(f"오류: {e}")
        sys.exit(1)

    print(f"=== {account_name} 계정 인증 ===")
    print(f"이메일: {email}")
    print()

    # 기존 토큰 확인
    creds = get_credentials(account_name)
    if creds:
        print("이미 유효한 인증이 존재합니다.")
        print("재인증하려면 토큰 파일을 삭제 후 다시 실행하세요:")
        print(f"  rm {TOKENS_DIR / f'{account_name}.json'}")
        return

    print("브라우저에서 Google 로그인 창이 열립니다.")
    print(f"반드시 {email} 계정으로 로그인하세요.")
    print()

    try:
        creds = authenticate(account_name)
        print(f"\n✅ {account_name} 계정 인증 완료!")
        print(f"   토큰 저장: {TOKENS_DIR / f'{account_name}.json'}")
    except Exception as e:
        print(f"\n❌ 인증 실패: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
