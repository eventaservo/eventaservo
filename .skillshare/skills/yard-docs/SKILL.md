---
name: yard-docs
description: Creates or updates YARD documentation for Ruby classes and methods per project rules. Use when the user asks for YARD docs, Ruby docstrings, or when adding or changing classes or methods that need documentation. Triggers on keywords like "YARD", "documentação", "documentation", "criar classe", "novo service", "nova factory". All YARD text must be in English.
---

# YARD Documentation in Eventaservo

## When to apply

- When creating or changing classes, modules, or methods in `app/`, `lib/`, or `config/`.
- When the user asks to document code, add YARD, or add "docstrings" in Ruby.
- During code review, when suggesting documentation for public APIs or services.

## Language

**All YARD documentation must be in English** (project default per AGENTS.md). Summaries, descriptions, and tag text must be written in English.

## Structure by element

### Class or module

1. **First line**: One-sentence summary (what it is / responsibility).
2. **Blank line** and, if needed, paragraphs explaining flow, preconditions, or exceptions.
3. **Tags** (when relevant):
   - `@example` for typical usage on public APIs (services, factories, presenters).
   - `@see ClassName` for related classes/modules (max 3–5).

```ruby
# Service for creating Log entries.
#
# Creates a Log record with optional user, text, metadata, and polymorphic
# loggable association. Falls back to system account when no user is provided.
#
# @example Create a log with all parameters
#   Logs::Create.call(text: "User logged in", user: current_user, loggable: event)
#
# @example Create a log without user (uses system account)
#   Logs::Create.call(text: "System event", loggable: organization)
#
# @see LogFactory
# @see Log
class Create < ApplicationService
```

### Method (public or private)

All methods — public **and** private — must be documented (per AGENTS.md).

1. **First line**: One-sentence summary.
2. **Blank line** and, if needed, details (special behavior, edge cases).
3. **Required tags**:
   - `@param name [Type] Description` for each argument (keyword or positional).
   - A **blank line** before `@return`.
   - `@return [Type] Description` (always; use `[void]` when there is no meaningful return value).

Common types: `String`, `Integer`, `Boolean`, `Hash`, `Array`, `BigDecimal`, `nil`, or class name (`User`, `Event`, `ApplicationService::Response`). For "may be nil": `[String, nil]`.

```ruby
# Creates a new Log entry.
#
# @param text [String, nil] the log text
# @param user [User, nil] the user performing the action
# @param loggable [Object, nil] polymorphic association (Event, Organization, etc.)
# @param metadata [Hash, nil] additional data to store as JSON
#
# @return [ApplicationService::Response] success with Log, or failure with error message
def call
```

### Private methods / helpers

Same pattern: one-line summary, optional description, `@param` and `@return`. No `@example` unless it is a complex shared helper.

```ruby
private

# Filters kwargs to only allowed attribute keys.
#
# @param kwargs [Hash] the raw keyword arguments
#
# @return [Hash] filtered attributes
def allowed_attributes(kwargs)
  kwargs.slice(*ALLOWED_ATTRIBUTES)
end
```

### Methods with **kwargs

Use Hash notation for kwargs:

```ruby
# Builds a new Log instance without saving to database.
#
# @param kwargs [Hash] loggable:, user:, text:, metadata:
#
# @return [Log] unsaved Log instance
def build(**kwargs)
```

### attr_reader / attr_writer / attr_accessor

Do **NOT** document these — keep them on a single line without comments:

```ruby
# Good
attr_reader :text, :user, :loggable

# Bad — avoid this
# @return [String, nil] the log text
attr_reader :text
```

## ApplicationService Response pattern

Services inherit from `ApplicationService` and return `ApplicationService::Response`:

```ruby
# @return [ApplicationService::Response] success with User payload or failure with error message
def call
  # ...
  success(user)
rescue => e
  failure(e.message)
end
```

The `Response` struct has `.success?`, `.payload`, and `.error` attributes.

## Rules

- **Consistency**: Match the style of the file you are editing.
- **Language**: All descriptions and tag text in English.
- **Brevity**: Clear, concise summaries; add detail only when it adds value.
- **Types**: Use correct YARD types; avoid vague docs like "returns something".
- **Blank line before `@return`**: Always separate params from return with a blank `#` line.
- **Do not document**: `attr_reader`, `attr_writer`, or `attr_accessor`; generated or pure-delegate code.
- **Do not use** the `@api` tag (not used in this project).
- **frozen_string_literal**: Always include `# frozen_string_literal: true` at the top of Ruby files (per AGENTS.md).

## Quick checklist

- [ ] Class/module: summary + description (if needed) + `@example`/`@see` when applicable.
- [ ] Each method (public AND private): summary + `@param` for all parameters + blank line + `@return`.
- [ ] Types in brackets (e.g. `[String, nil]`, `[ApplicationService::Response]`).
- [ ] All text in English and consistent with existing file style.

For full tag and type reference, see [reference.md](reference.md).
