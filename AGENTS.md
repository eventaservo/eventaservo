# Agent Guidelines for Eventaservo

## Commands
- **Tests**: `bin/rspec` (all), `bin/rspec spec/path/to/file_spec.rb` (single test)
- **Lint**: `bundle exec standardrb` (Ruby), no JS linter configured
- **Build**: `yarn build` (JS), `yarn build:css` (CSS)
- **Dev**: `bin/dev` (start development server)

## Code Style
- **Language**: Always use English for code, comments, specs, and commit messages
- **Ruby**: Use `standard` gem formatting, `frozen_string_literal: true` at top of files
- **Documentation**: Use YARD format (`@param`, `@return`) for all methods and classes
- **Schema**: Keep `annotate` gem annotations at top of models

## Architecture
- **Services**: Inherit from `ApplicationService`, return `Response` objects via `success()`/`failure()`
- **Organization**: Group services in modules by domain (e.g., `UserServices::Disable`)
- **Controllers**: Inherit from `ApplicationController`, use `helper_method` for view helpers
- **Presenters**: Use for complex view logic, include route helpers when needed

## Testing
- **Framework**: RSpec with FactoryBot for fixtures
- **Structure**: Use `subject`, `let`, and nested contexts for clarity
- **Types**: Specify test type (`:service`, `:controller`, etc.)

## Frontend
- **CSS**: Bootstrap 4.6 for all styling
- **JS**: Stimulus + Turbo with esbuild bundling