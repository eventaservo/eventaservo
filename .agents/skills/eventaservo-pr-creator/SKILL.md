---
name: eventaservo-pr-creator
description: >-
  Prepares branches and commits, then creates a GitHub pull request with `gh pr create`
  (auto-assigning @me) or updates title/body with `gh pr edit` when a PR already exists
  for the branch. PR descriptions are a short why-first executive summary in English (no
  technical changelog); emojis allowed. Use when the user asks to open or create a PR,
  update a PR description, or refresh pull request text. Follows Eventaservo AGENTS.md
  (Conventional Commits, English PR text, explicit permission before creating branches,
  commits, or PRs).
---

# Eventaservo Pull Request Creator

You help the user open or update a **GitHub Pull Request** for the **Eventaservo**
repository using the **GitHub CLI** (`gh`).

## Language

- This skill and all **preview text** you show for this flow are **English only**.
- The user may speak another language; **PR title and body** must still be **English**
  (project convention per `AGENTS.md`).

## Prerequisites

- **`gh` installed and authenticated** — if unsure, run `gh auth status`.
- The user must **explicitly** ask to create or update a PR (`AGENTS.md`: no branches,
  commits, or PRs without permission). Once the user has explicitly authorized
  creating or updating the PR, proceed directly through commit, push, and `gh`
  create/edit without stopping for a second confirmation of the PR text—unless the
  user asks to preview/review the text first or there are ambiguous unrelated local
  changes to resolve.

## Workflow

### 1. Inspect the working tree

- Run `git status` and review `git diff` (and `git diff --cached` if needed).
- **Exclude unrelated local changes** from the PR scope (e.g. personal
  `config/environments/development.rb` host tweaks). Ask whether those files should be
  **left unstaged** or included.

### 2. Branch

- Do **not** commit on `main` / default production branch. Use a feature branch.
- If the user is on the wrong branch, suggest a name such as
  `type/short-description-in-english` (e.g. `ci/improve-test-workflow`).

### 3. Ruby style (if applicable)

- For **`.rb` files included in the PR**, run `bundle exec standardrb --fix` on those
  paths before commit (`AGENTS.md`).

### 4. Tests in the diff

- If the change adds or restructures tests, read `TEST_ARCHITECTURE.md` before assuming
  layout or naming.

### 5. Commit message

- Use **Conventional Commits** in **English** (e.g. `feat:`, `fix:`, `chore:`).
- Optional body with short bullets is fine.

### 6. Detect an existing PR for this branch

- **Do not push before checking.** Pushing to `origin` happens in step 9.
- If the branch **already exists on `origin`** (e.g. `git rev-parse origin/<branch>`
  succeeds, or equivalent), check for an open PR, e.g.:
  - `gh pr list --head <branch> --json number,url,title,state`
  - or `gh pr view --branch <branch>` if supported by the installed `gh` version.
- If the branch is **not** on `origin` yet, **skip** this lookup. Assume
  **Create new PR** unless the user says a PR already exists; after you push in step 9,
  **run the same `gh` lookup again** before choosing `gh pr create` vs `gh pr edit`.
- If a PR exists, note its **number**, **URL**, and a **short summary** of current title/body.

### 7. Draft PR title and body

**Title:** Short, Conventional-Commits-style in English (e.g. `ci: improve test workflow`).

**Body — executive summary, why-first**

- **Focus on why this PR exists:** business or product context, problem, motivation, or
  decision — the reader must understand **why we are doing this**, not a catalog of
  **what** the PR implements.
- Do **not** make **what** the main topic. At most **one optional high-level sentence**
  may tie the why together — never replace the motivation or turn into a feature list.
- **No technical changelog:** no file lists, class names, endpoints, or implementation
  steps — the diff and commits already show that.
- **Length:** usually **one short paragraph**; **two** only if the second reinforces
  **context or urgency of the why** — never use the second paragraph as a changelog.
- **Emojis:** allowed in moderation when they support tone or context (e.g. motivation).
- Do **not** add long checklists or “How to test” unless the user explicitly asks.

### 8. Optional preview (only when requested or unconfirmed)

- If the user **already explicitly asked** to create/update the PR (e.g. "open a PR",
  "commit and create the PR"), **skip** the confirmation prompt and go straight to
  step 9.
- Only show a preview and wait for confirmation (`yes / edit / cancel`) if the user
  explicitly asked to review the PR text first, or if they have not yet authorized
  creating/updating the PR:

```text
**Branch:** <name>  →  **Base:** main (or user-specified)
**Action:** Create new PR  |  **Update existing PR #N**
**Proposed title:** ...
**Proposed body:**
---
[full body]
---

Proceed? (yes / edit / cancel)
```

### 9. Execute

1. `git add` (scoped to agreed files), `git commit` if there are staged/uncommitted
   changes the user wants in the PR.
2. `git push -u origin <branch>` if the remote is not up to date.
3. If step 6 was skipped because the branch was not on `origin` yet, run the PR lookup
   from step 6 now so you choose **create** vs **edit** correctly.

**If no PR exists:**

```bash
gh pr create --title "..." --body-file /path/to/body.md --assignee @me
```

Always assign the authenticated user (`--assignee @me`) when creating a PR. Prefer **`--body-file`** for multiline bodies. Add `--draft` only if the user asked.

**If a PR already exists:**

- Run `gh pr edit <number> --title "..." --body-file ...` when the summary or title
  should reflect the latest **why** or agreed wording.
- If the user only wanted to **ensure a PR exists** and the narrative is unchanged,
  do **not** rewrite the body without need — state that in the preview (“ensure only”).
- If `gh pr edit` fails due to GitHub's GraphQL `projectCards` deprecation, fall back to
  the REST API:
  - Update title and body:
    `gh api --method PATCH repos/{owner}/{repo}/pulls/<number> -f title="..." -f body="$(cat /path/to/body.md)"`
  - Add an assignee:
    `gh api repos/{owner}/{repo}/issues/<number>/assignees -f 'assignees[]=<login>'`

4. Print the **PR URL** (created or updated).

For extra `gh` options (reviewers, base branch other than `main`, labels), see
`gh pr create --help` and `gh pr edit --help`.

## After the PR is open

The user may run a follow-up review using the **eventaservo-code-review** skill when
needed.
