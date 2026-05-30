# YARD Reference – Tags and Types (Eventaservo)

## Tags used in the project

| Tag | Use | Example |
|-----|-----|---------|
| `@param` | Method parameter | `@param user [User] The user to regenerate token for` |
| `@return` | Return value | `@return [ApplicationService::Response] Success or failure` |
| `@example` | Usage example (public API) | Code block with typical call |
| `@see` | Related class/module | `@see LogFactory` |
| `@raise` | Exception that may be raised | `@raise [ActiveRecord::RecordInvalid]` |
| `@deprecated` | Deprecated method/class | `@deprecated Use OtherService instead` |
| `@note` | Important note | `@note Only for admin users` |

## Common types

- Primitives: `String`, `Integer`, `Float`, `Boolean`, `Symbol`, `NilClass`
- Collections: `Array`, `Hash` (optional: `Hash{Symbol => String}`)
- Numeric: `BigDecimal`, `Numeric`
- Nilable: `[String, nil]`, `[Integer, nil]`
- Multiple: `[String, Symbol]`
- App classes: `User`, `Event`, `Organization`, `Log`, `ApplicationService::Response`
- Generic: `void` for "no meaningful return value"
- Polymorphic: `Object` (e.g. for loggable associations)

## @param format

```
@param name [Type] Brief description
```

- Name must match the argument (keyword: `user`, not `:user`).
- Type in brackets; multiple types separated by comma: `[String, nil]`.
- Description on one line; break only if necessary.
- For `**kwargs`: `@param kwargs [Hash] key1:, key2:, key3:`

## @return format

Always put a **blank line** before `@return`.

```
@return [Type] Description of what is returned
```

- Exactly one `@return` per method.
- For side-effect-only methods: `@return [void]`.
- For ApplicationService methods: `@return [ApplicationService::Response] Success with X or failure with error message`.

## @example format

```ruby
# @example Basic usage
#   Logs::Create.call(text: "User logged in", user: current_user)
#
# @example Without user
#   Logs::Create.call(text: "System event", loggable: organization)
```

- Use for public APIs (services, factories, presenters).
- Show real, concrete usage — not abstract examples.
- Multiple `@example` blocks for different scenarios are encouraged.

## @raise format

```ruby
# @raise [ActiveRecord::RecordInvalid] if validation fails
# @raise [ArgumentError] if payment_type is invalid
```

## Full example (service class)

```ruby
# frozen_string_literal: true

module Users
  # Service to regenerate the API V2 JWT token for a user.
  # This service invalidates the old token and generates a new one.
  #
  # @example
  #   Users::RegenerateApiToken.call(user: current_user)
  #
  class RegenerateApiToken < ApplicationService
    attr_reader :user

    # @param user [User] The user for whom to regenerate the token
    def initialize(user:)
      @user = user
    end

    # Executes the token regeneration.
    #
    # @return [ApplicationService::Response] Success with user payload or failure with error message
    def call
      # ...
      success(user)
    rescue => e
      failure(e.message)
    end
  end
end
```

## Full example (factory)

```ruby
# frozen_string_literal: true

# Factory for creating Log instances.
#
# @example Build an unsaved Log
#   log = LogFactory.build(text: "My log", user: user)
#
# @example Create a persisted Log
#   log = LogFactory.create(text: "My log", user: user, loggable: event)
#
class LogFactory
  ALLOWED_ATTRIBUTES = %i[loggable user text metadata].freeze

  class << self
    # Builds a new Log instance without saving to database.
    #
    # @param kwargs [Hash] loggable:, user:, text:, metadata:
    #
    # @return [Log] unsaved Log instance
    def build(**kwargs)
      Log.new(allowed_attributes(kwargs))
    end

    # Creates and saves a new Log instance.
    #
    # @param kwargs [Hash] loggable:, user:, text:, metadata:
    #
    # @return [Log] persisted Log instance
    # @raise [ActiveRecord::RecordInvalid] if validation fails
    def create(**kwargs)
      Log.create!(allowed_attributes(kwargs))
    end

    private

    # Filters kwargs to only allowed attribute keys.
    #
    # @param kwargs [Hash] the raw keyword arguments
    #
    # @return [Hash] filtered attributes
    def allowed_attributes(kwargs)
      kwargs.slice(*ALLOWED_ATTRIBUTES)
    end
  end
end
```

## Links

- [YARD – Tags](https://rubydoc.info/gems/yard/file/docs/Tags.md)
- [YARD – Types](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md#types)
