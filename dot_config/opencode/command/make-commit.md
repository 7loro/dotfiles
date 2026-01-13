---
description: Generates a Git commit based on changes.
agent: build
model: google-vertex/gemini-3-flash-preview
---

Please check staged files are exist on the following git status:
!{git status}

If staged files are existed,
Please make a commit based on the following git diff:
!{git diff --staged}

If staged files are not existed,
Please make a commit based on the following git diff:
!{git diff}

Answer concisely and professionally.
Write in one line in 80 characters.
**Use korean for commit title except type.**

Follow these strict formatting guidelines:
- Format: type: description
- Add a space after the colon
- If $ARGUMENTS is provided (e.g., "feat", "fix"), use $ARGUMENTS as the 'type'.
- Otherwise, choose the 'type' from the list below: feat, fix, refactor, build, docs, style, test, chore
- after type: title should start with lowercase
- Example: feat: 사용자 로그인 기능 구현
- Example: fix: connection timeout 이슈 수정
- Example: chore: 환경 변수 업데이트

Common types to use:
- feat: new feature or functionality
- fix: bug fix
- chore: maintenance tasks, config changes
- docs: documentation changes
- style: code formatting, whitespace
- refactor: code restructuring without behavior change
- test: adding or updating tests
- build: build related files. app version up.

Keep the description concise and use imperative mood (e.g., "add" not "added").
Make a git commit.

After make a git commit, print below informations with korean exception git commit message using markdown syntax.

1. Summary of commit diff
2. How commit title is decided
3. git commit hash and commit message in one line.
