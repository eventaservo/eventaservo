# AGENTS.md

This file provides guidance to AI coding assistants (e.g., Cursor, Claude Code, Windsurf, etc.) when working with code in this repository.

## Project Overview

Eventa Servo is a Ruby on Rails application for organizing and publicizing Esperanto events worldwide. It's a system of UEA (Universal Esperanto Association) licensed under AGPLv3+.

## Supported Languages

The project supports three languages:
- **Esperanto (eo)**: Main language.
- **English (en)**
- **Portuguese (pt_BR)**

## Commands

- **Development server**: `bin/dev`
- **Tests**: `bin/rails test` (all), `bin/rails test test/path/to/file_test.rb` (single file)
- **System Tests**: `bin/rails test:system`
- **Lint**: `bundle exec standardrb` (check), `bundle exec standardrb --fix` (autofix)
- **Build JS**: `yarn build`
- **Build CSS**: `yarn build:css`
- **Docker Compose**: `docker-compose up`

## Code Style

- **Language**: Always use English for code, comments, specs, commit messages, PR titles, and PR descriptions
- **Commits**: Use **Conventional Commits** standard and always write messages in **English**
- **Ruby formatting**: Use `standard` gem; include `frozen_string_literal: true` at top of files. **Mandatory**: You **MUST** run `bundle exec standardrb --fix` on all modified `.rb` files before every commit and before submitting a PR.
- **Testing**: **Mandatory**: All new tests **MUST** follow the rules and directory organization defined in [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md).
- **Documentation**: Use YARD format (`@param`, `@return`) for all methods including private ones
- **Models**: Keep `annotate` gem schema annotations at top of model files
- **Named parameters**: Omit redundant variable names: `my_method(user:)` instead of `my_method(user: user)`

## Documentation

All classes, modules, and methods (including private ones) must be documented using [YARD](https://yardoc.org/).

### Example

```ruby
# Service to regenerate the API V2 JWT token.
#
class RegenerateApiToken < ApplicationService
  attr_reader :user

  # @param user [User] The user to regenerate token for
  def initialize(user:)
    @user = user
  end

  # Executes the logic
  #
  # @return [ApplicationService::Response]
  def call
    # ...
  end
end
```

## Services Pattern

- Use `attr_reader` for all service parameters. Access them via the reader method, not `@instance_variables`.
- Services inherit from `ApplicationService` and return `Response` objects
- Call with: `SomeService.call(args)` or `SomeService.new(args).call`

## Custom Factory Pattern

- Place domain factories in `app/factories/`
- Factories should have `build` and `create` module methods:
  ```ruby
  module LogFactory
    module_function

    def build(attributes = {})
      Log.new(attributes)
    end

    def create(attributes = {})
      Log.create!(attributes)
    end
  end
  ```

## Architecture

### Query Objects

Query objects encapsulate read-only query logic that returns ActiveRecord relations. Place them in `app/queries/<resource>/`. Unlike Services (which have side effects and return `Response` objects), query objects are for pure reads.

```ruby
module Users
  class TeachersAndSpeakersQuery
    def initialize(name: nil, country_id: nil)
      @name = name
      @country_id = country_id
    end

    def call
      # Returns a Result struct with ActiveRecord relations
    end
  end
end
```

Tests go in `test/queries/<resource>/<query_name>_test.rb`.

### Services
Services inherit from `ApplicationService` and return `Response` objects:
```ruby
module UserServices
  class Disable < ApplicationService
    def initialize(user)
      @user = user
    end

    def call
      if @user.update(disabled: true)
        success(@user)
      else
        failure("Failed to disable user")
      end
    end
  end
end
```
Call services with: `UserServices::Disable.call(user)` or `UserServices::Disable.new(user).call`

### Key Patterns
- **Controllers**: Inherit from `ApplicationController` (includes Pagy, Internationalization, Sentry, PaperTrail)
- **Presenters**: Used for complex view logic, located in `app/presenters/`
- **ViewComponents**: Located in `app/components/` for reusable UI elements
- **Jobs**: Solid Queue for background jobs, admin at `/jobs` for admin users

### API Structure
- **v1**: Legacy API at `/api/v1/`
- **v2**: JSON API at `/api/v2/` with events and organizations endpoints

### Feeds (RSS & Webcal)
Event feeds support multiple formats via `respond_to` blocks in controllers:

- **RSS feeds** (`.xml`): Add `.xml` to existing URLs
  - Country: `/europo/Montenegro.xml`, `/ameriko/Brazilo.xml`
  - Continent/Online: `/reta.xml`
  - Templates: `app/views/events/*.xml.builder`

- **Webcal feeds** (`.ics`): Calendar subscriptions via `Webcal` module
  - Country: `/webcal/lando/:country_code`
  - Organization: `/webcal/o/:short_name`
  - User: `/webcal/uzanto/:webcal_token`
  - Module: `app/modules/webcal.rb`

### Frontend
- **CSS**: Bootstrap 5.3
- **JS**: Stimulus + Turbo (Hotwire) with esbuild bundling
- **Maps**: Leaflet with marker clustering
- **UI Mockups**: Before creating or modifying UI components, **always** check the mockups at `app/views/admin/mockups/` for established patterns (tables, breadcrumbs, cards, etc.). Use the existing patterns to ensure visual consistency across the application.
- **Admin Breadcrumbs**: Every admin page **must** include a breadcrumb navigation at the top (before the main content). Use the pattern from `app/views/admin/mockups/breadcrumbs.html.erb` as reference. The breadcrumb follows the hierarchy: `Admin > Section > Page`.

## Testing

**🚨 CRITICAL - READ FIRST**: Before creating or modifying **any** test, you **MUST** read and follow [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) in its entirety. This is a **mandatory prerequisite** — do not write test code until you have read it. Every test must comply with its rules.

That document contains:
- ✅ Complete test architecture rules
- ✅ Directory organization patterns
- ✅ Naming conventions and templates
- ✅ Fixtures vs FactoryBot decision guide
- ✅ Step-by-step instructions for AI agents (Section 9)
- ✅ Code review checklist

### Quick Reference

- **Framework**: Minitest (`test/`)
- **Test Data**: **Always prefer Fixtures over FactoryBot**
- **Directory Structure**: Organized by responsibility
  - Models: `test/models/<model>/<context>_test.rb`
  - Controllers: `test/controllers/<controller>/<action>_test.rb`
  - Services: `test/services/<resource_plural>/<service_name>_test.rb`
  - Queries: `test/queries/<resource_plural>/<query_name>_test.rb`
- **Namespacing**:
  - Models: `Event::ValidationTest`
  - Controllers: `EventsController::IndexTest`
  - Services: `Events::SoftDeleteTest`
  - Queries: `Users::TeachersAndSpeakersQueryTest`

### Mandatory Checklist Before Writing Tests

- [ ] Read [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) Section 9 (AI Agent Instructions)
- [ ] Check if fixtures exist for the data you need
- [ ] Verify the correct directory structure
- [ ] Use the appropriate template from the guidelines
- [ ] Use fixtures unless there's a justified reason for FactoryBot

## Important Notes

- Do not create branches, commits, or PRs without explicit user permission
- Error tracking via Sentry (`Sentry.capture_exception(e)`)
- Localization managed via Lokalise
- **Database**: The project uses PostgreSQL, configured in `docker-compose.yml`.- **Commit Pattern**: All commits must follow the **Conventional Commits** specification (e.g., `feat:`, `fix:`, `chore:`, `docs:`) and must be in **English**.
