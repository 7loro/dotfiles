---
description: Check github pull request and review
agent: plan
model: github-copilot/gpt-5.2
---

Please provide a detailed pull request review on GitHub issue: $ARGUMENTS.

Follow these steps:

1. Use `gh pr view $ARGUMENTS` to pull the information of the PR.
2. Use `gh pr diff $ARGUMENTS` to view the diff of the PR.
3. Understand the intent of the PR using the PR description.
4. Search the codebase if required.
5. Use flutter mcp, context7 mcp if required.
6. Write review in Korean.
7. If all content is good, don't need to write a comment. Just let me know the result.
8. Write a concise review of the PR, keeping in mind to encourage strong code quality and best practices. Do not post before asking to user.
9. Must ask the user before post the review to the PR.
10. Let me know whether pull request looks good to merge, and ask user to approve it or not.
11. Use `gh pr comment $ARGUMENTS --body {{review}}` to post the review to the PR. If user approves pull request, then use `-a` argument to approve pr.

Remember to use the GitHub CLI (`gh`) with the Shell tool for all GitHub-related tasks.
