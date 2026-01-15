---
name: explain-branch
description: Explain current branch changes compared to main
---

Current git status: !`git status`
Commits on this branch: !`git log --oneline main..HEAD`
Changes compared to main: !`git diff main...HEAD`

Explain what changes were made in the current branch compared to main. Provide a clear summary of:
1. What features/fixes were implemented
2. What files were modified and why
3. The overall purpose of this branch

Keep the explanation concise and focused on the intent behind the changes.
