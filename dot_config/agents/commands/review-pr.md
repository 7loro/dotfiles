---
description: Check github pull request and review
agent: plan
---

Please provide a detailed pull request review on GitHub pull request: $ARGUMENTS.

Follow these steps:

1. Use `gh pr view $ARGUMENTS` to pull the information of the PR (title, body, labels, base/head, checks).
2. Checkout the PR branch locally to enable deeper review beyond diff:
   - Prefer: `gh pr checkout $ARGUMENTS`
   - If needed: `gh pr view $ARGUMENTS --json headRepository,headRefName,baseRefName` and then `git fetch <remote> <headRefName> && git checkout <headRefName>`
3. Run `dart run build_runner build --delete-conflicting-outputs` to generate necessary code files.
4. Use `gh pr diff $ARGUMENTS` to view the diff of the PR.
5. Understand the intent of the PR using the PR description.
6. Review the checked-out branch for additional context:
   - Search the codebase if required.
   - Open and inspect related files not fully visible in the diff (generated files, config, templates, etc.).
   - If relevant, run or outline local verification steps (tests/build/lint) that help validate behavior.
7. Use flutter mcp, context7 mcp if required.
8. Write review in Korean.
9. If all content is good, don't need to write a comment. Just let me know the result.
10. Write a concise review of the PR, keeping in mind to encourage strong code quality and best practices. Do not post before asking the user.
11. Must ask the user before posting the review to the PR.
12. Let me know whether pull request looks good to merge, and ask user to approve it or not.
13. Use `gh pr comment $ARGUMENTS --body {{review}}` to post the review to the PR. If the user approves the pull request, then use `-a` to approve the PR.

Remember to use the GitHub CLI (`gh`) with the Shell tool for all GitHub-related tasks.
