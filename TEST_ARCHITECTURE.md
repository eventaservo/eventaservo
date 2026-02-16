# Test Architecture Reorganization Proposal

This document details the analysis of the Ruby on Rails application's current test structure and proposes a new modularized architecture, focused on scalability, maintainability, and ease of AI automation.

## 1. Analysis of Current Organization

The application uses Minitest and follows a standard monolithic Rails structure, but presents inconsistencies and files that tend to grow disorderly.

### Existing Structure
- **`test/models/`**: Single files per model (e.g., `event_test.rb` with ~200 lines). They mix validations, scopes, instance methods, and callbacks in a single file.
- **`test/controllers/`**: Single files per controller (e.g., `events_controller_test.rb`). They use nested classes (`class NewTest < EventsControllerTest`) to separate contexts, which helps with logical organization but keeps everything in the same physical file.
- **`test/services/`**: Inconsistent organization. Some directories use the `_services` suffix (e.g., `test/services/event_services/`) while others use the resource name in plural (e.g., `test/services/events/`).
- **Factories (`test/factory_bot/`)**: Defined outside the standard `test/factories/`. Factories like `event` create heavy associations by default, making tests slow.
- **Fixtures (`test/fixtures/`)**: Already used for static data (`countries.yml`, `tags.yml`), which is a positive practice.

### Identified Problems
1.  **Monolithic Files**: `test/models/event_test.rb` and `test/controllers/events_controller_test.rb` accumulate many responsibilities, making reading and maintenance difficult.
2.  **Difficulty of Location**: Finding a specific test within a 200+ line file requires textual search.
3.  **Inconsistency in Services**: The mix of naming patterns (`event_services` vs `events`) confuses the structure.
4.  **Coupling in Controllers**: The use of nested classes in a single file creates implicit dependencies and makes it difficult to run a specific context in isolation via the command line simply.
5.  **Heavy Factories**: Factories create unnecessary data for simple tests (e.g., validation), impacting performance.

## 2. New Modularized Test Architecture

The proposal aims to split large files into smaller, focused components, facilitating test generation by AI and human maintenance.

### Fundamental Principles
1.  **One File, One Responsibility**: Each test file must focus on a specific aspect (validation, scope, controller action).
2.  **Size Limit**: Files should not exceed **200 lines**. If they do, they must be refactored into sub-contexts.
3.  **Independence**: Tests must be able to run in isolation without depending on complex global states defined in parent classes.
4.  **Fixtures > Factories**: Use Fixtures for static or reference data. Use Factories only when data variability is essential.

### Proposed Directory Organization

#### Models (`test/models/<model_name>/`)
Instead of `test/models/event_test.rb`, we will have a directory:

```ruby
test/models/event/
├── validation_test.rb    # Validation tests (presence, length, format)
├── association_test.rb   # Association tests (belongs_to, has_many)
├── scope_test.rb         # Scope tests (past?, online?, etc)
├── method_test.rb        # Complex instance method tests
└── callback_test.rb      # Callback tests (if there is complex logic)
```

#### Controllers (`test/controllers/<controller_name>/`)
Instead of `test/controllers/events_controller_test.rb`, we will have a directory with independent tests per action:

```ruby
test/controllers/events/
├── index_test.rb         # Tests for GET /events
├── show_test.rb          # Tests for GET /events/:code
├── create_test.rb        # Tests for POST /events
├── update_test.rb        # Tests for PATCH/PUT /events/:code
└── destroy_test.rb       # Tests for DELETE /events/:code
```

#### Services (`test/services/<resource_plural>/`)
Standardization to use the resource name in plural, eliminating redundant suffixes like `_services`.

```ruby
test/services/events/     # Before: test/services/event_services/
├── move_to_system_account_test.rb
├── schedule_reminders_test.rb
└── soft_delete_test.rb
```

## 3. Naming and Code Conventions

### Test Classes
Must reflect the file path to facilitate autoloading and location.

**Model:**
```ruby
# test/models/event/validation_test.rb
require "test_helper"

class Event::ValidationTest < ActiveSupport::TestCase
  test "validates presence of title" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end
end
```

**Controller:**
Controller tests must inherit directly from `ActionDispatch::IntegrationTest` (or `IntegrationTest` if configured), avoiding nesting in empty "Parent" classes.

```ruby
# test/controllers/events/index_test.rb
require "test_helper"

class Events::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get events_url
    assert_response :success
  end
end
```

### Factories and Fixtures

**Location:**
- Factories: Keep in `test/factory_bot/` (as per current preference).
- Fixtures: Keep in `test/fixtures/`.

**Strategy:**
1.  **Fixture First**: For fixed domain tables (Countries, Tags, Roles), always use Fixtures.
2.  **Minimal Factory**: The default factory (`:event`) must contain only what is strictly necessary for the object to be valid.
3.  **Traits for Complexity**: Use traits to add associations or complex states.

```ruby
# Example of Optimized Factory
FactoryBot.define do
  factory :event do
    title { "Simple Event" }
    association :user # Mandatory

    trait :with_participants do
      after(:create) { |event| create_list(:participant, 3, event: event) }
    end
  end
end
```

## 4. Gradual Migration Guide

Do not try to migrate everything at once. Follow this order to avoid CI/CD breakage:

1.  **Standardize Services**:
    - Move `test/services/event_services/` to `test/services/events/`.
    - Adjust namespaces in the moved files.

2.  **Refactor Critical Models (Ex: Event)**:
    - Create directory `test/models/event/`.
    - Create `validation_test.rb` and move validation tests from `event_test.rb`.
    - Create `scope_test.rb` and move scope tests.
    - Keep `event_test.rb` only with what remains, until it is empty and can be removed.

3.  **Refactor Critical Controllers (Ex: EventsController)**:
    - Create directory `test/controllers/events/`.
    - Extract `IndexTest` class to `test/controllers/events/index_test.rb`.
    - Remove the nested class from the original file.
    - Repeat for other actions.

## 5. Guidelines for Automation (AI)

When requesting new tests from an AI, provide these rules:
- "Create the test in `test/models/<model>/<context>_test.rb`."
- "Do not add to the main model file."
- "Use Fixtures for static data if available."
- "Keep the file under 200 lines."
