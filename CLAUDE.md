# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eventa Servo is a Ruby on Rails application for organizing and publicizing Esperanto events worldwide. It's a system of UEA (Universal Esperanto Association) licensed under AGPLv3+.

## Commands

- **Development server**: `bin/dev`
- **Tests (RSpec)**: `bin/rspec` (all), `bin/rspec spec/path/to/file_spec.rb` (single file)
- **Tests (Minitest)**: `bin/rails test` (all), `bin/rails test test/path/to/file_test.rb` (single file)
- **Lint**: `bundle exec standardrb` (check), `bundle exec standardrb --fix` (autofix)
- **Build JS**: `yarn build`
- **Build CSS**: `yarn build:css`

## Code Style

- **Language**: Always use English for code, comments, specs, and commit messages
- **Ruby formatting**: Use `standard` gem; include `frozen_string_literal: true` at top of files
- **Documentation**: Use YARD format (`@param`, `@return`) for methods and classes
- **Models**: Keep `annotate` gem schema annotations at top of model files
- **Named parameters**: Omit redundant variable names: `my_method(user:)` instead of `my_method(user: user)`

## Architecture

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

### Frontend
- **CSS**: Bootstrap 4.6
- **JS**: Stimulus + Turbo (Hotwire) with esbuild bundling
- **Maps**: Leaflet with marker clustering

## Testing

- **RSpec** (`spec/`): Primary test framework with FactoryBot
- **Minitest** (`test/`): Secondary framework, also uses FactoryBot and fixtures

```ruby
RSpec.describe UserServices::Disable, type: :service do
  subject(:service) { described_class.new(user) }
  let(:user) { create(:user) }

  describe '#call' do
    it 'disables user successfully' do
      expect(service.call).to be_success
    end
  end
end
```

## Important Notes

- Do not create branches, commits, or PRs without explicit user permission
- Error tracking via Sentry (`Sentry.capture_exception(e)`)
- Localization managed via Lokalise
