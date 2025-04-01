# Git Development Workflow Guide

## Basic Concepts

### Branches
- A branch is like a separate line of development
- `main` is your primary/production branch
- When you create a new branch, it starts as a copy of whatever branch you're currently on
- `git branch` shows all branches
- `git branch -D branchname` deletes a branch

### Checkout
- `git checkout branchname` switches to an existing branch
- `git checkout -b newbranch` creates AND switches to a new branch
- Example: `git checkout -b dev/error-handling` creates a new branch from your current position

### Reset
- `git reset --hard origin/main` discards ALL local changes and makes your branch exactly match the remote main
- `git reset --hard HEAD~1` goes back one commit
- Very destructive - use carefully! Only use on development branches, not main

### Merge
- Combines changes from one branch into another
- You first checkout the branch you want to merge INTO
- Then merge FROM the other branch
- Example:
  ```bash
  git checkout main          # Switch to main branch
  git merge dev/error-handling  # Bring changes from dev into main
  ```

### Push
- `git push origin main` pushes your local main branch to the remote repository
- `git push origin dev/error-handling` pushes your development branch to remote
- The difference:
  - `push origin main` updates the production branch
  - `push origin dev/error-handling` creates/updates a separate branch on remote

## Typical Workflow

1. Create and switch to dev branch:
   ```bash
   git checkout -b dev/error-handling
   ```

2. Make changes and commit them:
   ```bash
   # Make code changes
   git add .
   git commit -m "Added error handling"
   ```

3. Push dev branch to remote (optional, for backup):
   ```bash
   git push origin dev/error-handling
   ```

4. When feature is complete:
   ```bash
   git checkout main          # Switch to main
   git merge dev/error-handling  # Merge changes
   git push origin main      # Update remote main
   ```

5. If things go wrong in dev branch:
   ```bash
   # Option 1: Reset dev branch to match main
   git checkout dev/error-handling
   git reset --hard origin/main

   # Option 2: Delete and recreate dev branch
   git checkout main
   git branch -D dev/error-handling
   git checkout -b dev/error-handling
   ```

## Benefits of Using Development Branches

1. **Safety**: The main branch remains stable and untouched while you experiment
2. **Isolation**: You can work on features or fixes without affecting the production code
3. **Easy rollback**: If something goes wrong, you can simply delete the branch instead of resetting main
4. **Better collaboration**: Multiple people can work on different features in separate branches
5. **Code review**: Changes can be reviewed through pull requests before merging to main 