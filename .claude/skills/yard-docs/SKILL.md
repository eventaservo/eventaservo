---
name: yard-docs
description: Create YARD documentation for Ruby classes and methods. Use when creating new classes, factories, services, models, or when explicitly asked to add YARD documentation. Triggers on keywords like "YARD", "documentação", "documentation", "criar classe", "novo service", "nova factory".
---

# YARD Documentation Skill

This skill creates consistent YARD documentation for Ruby code in this project.

## When to Use

- Creating new classes (factories, services, models, presenters)
- Adding new public methods
- When explicitly asked to document code with YARD
- After refactoring when documentation needs updating

## Documentation Patterns

### Classes

Always document classes with:
- Brief description (1 line)
- `@example` blocks showing common usage patterns

```ruby
# Service for creating Log entries.
#
# @example Create a log with all parameters
#   Logs::Create.call(text: "User logged in", user: current_user, loggable: event)
#
# @example Create a log without user (uses system account)
#   Logs::Create.call(text: "System event", loggable: organization)
#
class Create < ApplicationService
```

### Methods with Named Parameters

Document each parameter with `@param`:

```ruby
# @param text [String, nil] the log text
# @param user [User, nil] the user performing the action
# @param loggable [Object, nil] polymorphic association (Event, Organization, etc.)
def initialize(text: nil, user: nil, loggable: nil)
```

### Methods with **kwargs

Use Hash notation for kwargs:

```ruby
# @param kwargs [Hash] loggable:, user:, text:
# @return [Log] unsaved Log instance
def build(**kwargs)
```

### Return Values

Always document return types:

```ruby
# @return [Log] persisted Log instance
# @raise [ActiveRecord::RecordInvalid] if validation fails
def create(**kwargs)
```

For services returning Response objects:

```ruby
# @return [Response] success with Log, or failure with error message
def call
```

### attr_reader

Do NOT document `attr_reader` - keep them on a single line without comments:

```ruby
# Good
attr_reader :text, :user, :loggable

# Bad - avoid this
# @return [String, nil] the log text
attr_reader :text
```

## Project-Specific Patterns

### Factories

```ruby
# Factory for creating Log instances.
#
# @example Build an unsaved Log
#   log = LogFactory.build(text: "My log", user: user)
#   log.save
#
# @example Create a persisted Log
#   log = LogFactory.create(text: "My log", user: user, loggable: event)
#
class LogFactory
  ALLOWED_ATTRIBUTES = %i[loggable user text].freeze

  class << self
    # @param kwargs [Hash] loggable:, user:, text:
    # @return [Log] unsaved Log instance
    def build(**kwargs)
```

### Services (ApplicationService)

```ruby
# Service for creating Log entries.
#
# @example Create a log with all parameters
#   Logs::Create.call(text: "User logged in", user: current_user, loggable: event)
#
class Create < ApplicationService
  attr_reader :text, :user, :loggable

  # @param text [String, nil] the log text
  # @param user [User, nil] the user performing the action
  # @param loggable [Object, nil] polymorphic association (Event, Organization, etc.)
  def initialize(text: nil, user: nil, loggable: nil)
```

## Rules

1. **Be concise** - one line descriptions when possible
2. **Use @example** - show real usage, not abstract examples
3. **Document all public methods** - private methods don't need YARD
4. **No redundant docs** - don't document obvious things
5. **Prefer types** - always include `[Type]` in @param and @return
6. **Nil types** - use `[Type, nil]` when nil is valid
7. **Portuguese is OK** - match the language used in the codebase/conversation
