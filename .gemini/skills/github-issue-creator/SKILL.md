---
name: github-issue-creator
description: Creates GitHub Issues for the Eventaservo project interactively. Use this skill whenever the user mentions creating a new issue or story — even casual requests like vamos criar uma issue or nova story. A story is a user story (Como [usuário], quero [ação] para [benefício]); an issue is any other GitHub issue (bug, chore, enhancement, etc.). The skill interviews the user, infers type and labels, drafts the full body, shows a preview for approval, then creates it via the GitHub CLI. Always use this skill for new issue creation.
---

# GitHub Issue Creator

You are helping the user create a GitHub Issue for the **Eventaservo** project.

## Workflow

### 1. Collect the title

If the user hasn't provided a title yet, ask for a short one. Suggest following
Conventional Commits style: `type: short description in English`.

Common types for this project: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`.

If the user gives a vague idea, ask as many questions as needed to sharpen it before drafting.

### 2. Determine the issue type

Based on the title and context, decide:

- **story** — if the user said "story" or the issue is about user-facing functionality
  (use the user story template)
- **issue** — everything else: bug, chore, enhancement, dependency upgrade, refactor, etc.

### 3. Infer labels

Choose from the project's labels based on the issue content. You decide — don't ask
the user about labels.

| Label | When to use |
|---|---|
| `cimo` | It's a bug |
| `plibonigo` | New feature or enhancement |
| `chore` | Maintenance, refactoring, dependency updates |
| `dependencies` | Dependency upgrade or removal |
| `ruby` | Primarily touches Ruby/Rails code |
| `javascript` | Primarily touches JS/CSS/frontend code |
| `! prioritata` | Urgent / high priority |
| `malprioritata` | Low priority, can wait |
| `dubo` | Needs clarification before work starts |

Multiple labels are fine (e.g., `chore` + `ruby`).

### 4. Draft the issue body

**For an issue:**

```markdown
## Goal

[What needs to be done — one clear sentence or short paragraph]

## Motivation

[Why this matters — bullet points]

## Scope

- [Key tasks or areas to touch]

## Notes

[Constraints, dependencies on other issues, things to watch out for]
```

**For a story:**

```markdown
## User Story

Como [tipo de usuário], quero [ação/funcionalidade] para [benefício/objetivo].

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Notes

[Technical notes, dependencies, or design considerations]
```

Omit sections that have nothing meaningful to say. Don't add filler text.

### 5. Show the preview

Before creating anything, show the full plan:

```
**Title:** chore: upgrade Bootstrap 4 → Bootstrap 5.3
**Labels:** chore, javascript, dependencies
**Body:**
---
[full body here]
---

Shall I create this issue? (yes / edit / cancel)
```

Wait for the user to confirm.

- **yes** → proceed to step 6
- **edit** → ask what to change, update, show preview again
- **cancel** → stop, do nothing

### 6. Create the issue

```bash
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --label "<label1>" \
  --label "<label2>"
```

Then show the user the URL of the created issue.

## Guidelines

- All issue content (title, body) must be in **English** — project convention.
- Keep the body focused and honest — no padding, no placeholder text.
- For chores, naming the tool/dependency in the title is good practice:
  `chore: remove FullCalendar — replace with native Rails/Hotwire calendar`
- Never create the issue without showing the preview first.
