# Claude Code Skills

This directory contains custom skills for Claude Code specific to this project.

## Available Skills

### 1. test-builder

**Purpose**: Create tests following the project's test architecture guidelines.

**When to use**:
- Creating tests for models, controllers, services
- Adding test coverage for existing code
- When asked to create or modify tests

**Triggers**: "test", "teste", "spec", "create test", "add test", "test coverage"

**Key Features**:
- Enforces fixture-first approach (prefer fixtures over FactoryBot)
- Follows TEST_ARCHITECTURE.md guidelines
- Correct directory structure and namespacing
- Arrange-Act-Assert pattern
- Step-by-step workflow

**Usage**:
```
/test-builder
```

### 2. yard-docs

**Purpose**: Create YARD documentation for Ruby classes and methods.

**When to use**:
- Creating new classes (factories, services, models)
- Adding new public methods
- When explicitly asked to document code with YARD
- After refactoring when documentation needs updating

**Triggers**: "YARD", "documentação", "documentation", "criar classe", "novo service", "nova factory"

**Usage**:
```
/yard-docs
```

## Creating New Skills

To create a new skill:

1. Create a directory under `.claude/skills/`
2. Add a `SKILL.md` file with frontmatter:
   ```markdown
   ---
   name: skill-name
   description: What the skill does. Triggers on keywords like "keyword1", "keyword2".
   ---

   # Skill Name

   [Content here]
   ```

3. The skill will be automatically detected by Claude Code

## References

- [TEST_ARCHITECTURE.md](/eventaservo/TEST_ARCHITECTURE.md) - Complete test guidelines
- [AGENTS.md](/eventaservo/AGENTS.md) - General project conventions
- [CLAUDE.md](/eventaservo/CLAUDE.md) - Claude-specific instructions
- [geminar.md](/eventaservo/geminar.md) - Gemini-specific instructions
