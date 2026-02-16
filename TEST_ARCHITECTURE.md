# Test Architecture Guidelines

This document defines the rules and instructions for creating new tests in the Rails application using Minitest. The goal is to maintain a coherent, organized, and easy-to-read standard.

> **For AI Agents**: This document is referenced by [AGENTS.md](AGENTS.md), [CLAUDE.md](CLAUDE.md), and [geminar.md](geminar.md). Section 9 contains specific instructions for AI assistants.

## Table of Contents

1. [Fundamental Principles](#1-fundamental-principles)
2. [Directory Organization](#2-directory-organization)
3. [Naming and Code Conventions](#3-naming-and-code-conventions)
4. [Factories and Fixtures](#4-factories-and-fixtures)
5. [Test Writing Patterns](#5-test-writing-patterns)
6. [Guidelines for New Tests](#6-guidelines-for-new-tests)
7. [Code Review Checklist](#7-code-review-checklist)
8. [Useful Commands](#8-useful-commands)
9. [Instructions for AI Agents](#9-instructions-for-ai-agents) ⭐
10. [Migrating Existing Tests](#10-migrating-existing-tests)

## 1. Fundamental Principles

1. **One File, One Responsibility**: Each test file should focus on a specific aspect (validation, scope, controller action).
2. **Independence**: Tests must be able to run in isolation without depending on complex global states defined in parent classes.
3. **Prefer Fixtures Over Factories**: Always use Fixtures as the default choice for test data. Use FactoryBot only when you truly need dynamic data or when fixtures become impractical. Fixtures are faster, simpler, and easier to maintain.

## 2. Directory Organization

### Models (`test/models/<model_name>/`)

Each model should have its own directory with tests separated by responsibility:

```
test/models/event/
├── validation_test.rb    # Validation tests (presence, length, format)
├── association_test.rb   # Association tests (belongs_to, has_many)
├── scope_test.rb         # Scope tests (past?, online?, etc)
├── method_test.rb        # Complex instance method tests
└── callback_test.rb      # Callback tests (if there is complex logic)
```

### Controllers (`test/controllers/<controller_name>/`)

Each controller should have a directory with independent tests per action:

```
test/controllers/events/
├── index_test.rb         # Tests for GET /events
├── show_test.rb          # Tests for GET /events/:code
├── create_test.rb        # Tests for POST /events
├── update_test.rb        # Tests for PATCH/PUT /events/:code
└── destroy_test.rb       # Tests for DELETE /events/:code
```

### Services (`test/services/<resource_plural>/`)

Services should use the resource name in plural, without redundant suffixes like `_services`:

```
test/services/events/
├── move_to_system_account_test.rb
├── schedule_reminders_test.rb
└── soft_delete_test.rb
```

## 3. Naming and Code Conventions

### Test Classes for Models

Must reflect the file path to facilitate autoloading and location:

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

### Test Classes for Controllers

Must inherit directly from `ActionDispatch::IntegrationTest` (or `IntegrationTest` if configured), avoiding nesting in empty "Parent" classes:

```ruby
# test/controllers/events/index_test.rb
require "test_helper"

class EventsController::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get events_url
    assert_response :success
  end
end
```

### Test Classes for Services

Must follow the namespace pattern based on the directory:

```ruby
# test/services/events/soft_delete_test.rb
require "test_helper"

class Events::SoftDeleteTest < ActiveSupport::TestCase
  test "marks event as deleted" do
    event = create(:event)
    Events::SoftDelete.call(event)
    assert event.reload.deleted?
  end
end
```

## 4. Factories and Fixtures

### Location
- **Factories**: Keep in `test/factory_bot/`
- **Fixtures**: Keep in `test/fixtures/`

### Usage Strategy

**Default to Fixtures**: Fixtures should be your first choice for test data. They are:
- Faster to load (preloaded into the database)
- Easier to understand (YAML files are simple and readable)
- More maintainable (one place to update test data)
- Better for referential integrity (all relationships are explicit)

**When to Use Fixtures**:
- ✅ Reference data (Countries, Tags, Roles, Categories)
- ✅ User accounts for authentication tests
- ✅ Standard test scenarios that are reused across multiple tests
- ✅ Related data that needs consistent relationships
- ✅ Most model and controller tests

**When to Use FactoryBot** (only when necessary):
- Dynamic data that changes between test runs (timestamps, random values)
- Tests that specifically require data variability
- Complex object graphs that are difficult to express in YAML
- Parameterized tests where you need to generate multiple variations

**Factory Guidelines** (when you must use them):
1. **Minimal Factory**: The default factory should contain only what is strictly necessary for the object to be valid
2. **Traits for Complexity**: Use traits to add associations or complex states
3. **Avoid Nested Factories**: Don't create deep association chains by default

### Optimized Factory Example

```ruby
# test/factory_bot/events.rb
FactoryBot.define do
  factory :event do
    title { "Simple Event" }
    description { "Event description" }
    starts_at { 1.day.from_now }
    ends_at { 2.days.from_now }
    association :user # Required

    # DO NOT create heavy associations by default
    # Use traits for that

    trait :with_participants do
      after(:create) { |event| create_list(:participant, 3, event: event) }
    end

    trait :with_location do
      association :location
    end

    trait :published do
      published_at { 1.hour.ago }
    end
  end
end
```

### Fixture Usage Examples

**Simple Reference Data:**
```ruby
# test/fixtures/countries.yml
brazil:
  code: BR
  name: Brazil

portugal:
  code: PT
  name: Portugal
```

**Users with Associations:**
```ruby
# test/fixtures/users.yml
john:
  name: John Doe
  email: john@example.com
  country: brazil

mary:
  name: Mary Jane
  email: mary@example.com
  country: portugal
```

**Events with Relationships:**
```ruby
# test/fixtures/events.yml
rails_conference:
  title: Rails Conference 2024
  description: Annual Rails conference
  starts_at: <%= 1.month.from_now %>
  ends_at: <%= 1.month.from_now + 3.days %>
  user: john

ruby_meetup:
  title: Ruby Meetup
  description: Monthly Ruby meetup
  starts_at: <%= 2.weeks.from_now %>
  ends_at: <%= 2.weeks.from_now + 4.hours %>
  user: mary
```

**Using Fixtures in Tests:**
```ruby
# In the test
test "user must have a valid country" do
  user = users(:john)
  assert user.valid?
  assert_equal "Brazil", user.country.name
end

test "event belongs to user" do
  event = events(:rails_conference)
  assert_equal users(:john), event.user
end

test "can create event with fixture data" do
  event = events(:rails_conference)
  assert event.persisted?
  assert_equal "Rails Conference 2024", event.title
end
```

## 5. Test Writing Patterns

### Test Naming

Use descriptive names that clearly explain the expected behavior:

```ruby
# ✅ GOOD
test "validates presence of title"
test "returns only published events"
test "creates event with valid attributes"

# ❌ BAD
test "title"
test "scope"
test "create"
```

### Organization Within the File

1. **Common setup** at the top (if necessary)
2. **Success cases** first
3. **Error cases** after
4. **Edge cases** last

```ruby
class Event::ValidationTest < ActiveSupport::TestCase
  # Common setup (if necessary)
  def setup
    @user = create(:user)
  end

  # Success cases
  test "is valid with all required attributes" do
    event = Event.new(title: "Test", user: @user)
    assert event.valid?
  end

  # Error cases
  test "is invalid without title" do
    event = Event.new(user: @user)
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  # Edge cases
  test "is invalid with title longer than 255 characters" do
    event = Event.new(title: "a" * 256, user: @user)
    assert_not event.valid?
  end
end
```

### Clear Assertions

Prefer specific assertions over generic ones:

```ruby
# ✅ GOOD
assert_includes event.errors[:title], "can't be blank"
assert_equal 3, Event.published.count
assert_redirected_to event_path(event)

# ❌ BAD
assert event.errors.any?
assert Event.published.count > 0
assert_response 302
```

## 6. Guidelines for New Tests

When creating a new test, follow these rules:

1. **Locate correctly**: Use the directory structure defined above
2. **Appropriate class**: Use the correct namespace based on the file path
3. **One responsibility**: Focus on a single aspect of behavior
4. **Prefer Fixtures**: Default to using fixtures for test data. Only use FactoryBot when fixtures are truly impractical
5. **Minimal data**: Use only the data necessary for the test
6. **Descriptive names**: The test name should make it clear what is being tested
7. **Specific assertions**: Use assertions that make it clear what is being verified

### Template for Model Test

```ruby
# test/models/<model>/<context>_test.rb
require "test_helper"

class <Model>::<Context>Test < ActiveSupport::TestCase
  test "describe expected behavior" do
    subject = <model_plural>(:fixture_name)
    result = subject.some_method

    assert_equal expected, result
  end
end
```

### Template for Controller Test

```ruby
# test/controllers/<controller>/<action>_test.rb
require "test_helper"

class <Controller>Controller::<Action>Test < ActionDispatch::IntegrationTest
  test "describe expected behavior" do
    user = users(:fixture_name)
    sign_in user

    get resource_url

    assert_response :success
  end
end
```

### Template for Service Test

```ruby
# test/services/<resource_plural>/<service_name>_test.rb
require "test_helper"

class <ResourcePlural>::<ServiceName>Test < ActiveSupport::TestCase
  test "describe expected behavior" do
    resource = <resource_plural>(:fixture_name)

    result = <ResourcePlural>::<ServiceName>.call(resource)

    assert result.success?
  end
end
```

## 7. Code Review Checklist

When reviewing new tests, verify:

- [ ] File is in the correct directory (`test/models/<model>/`, `test/controllers/<controller>/`, etc)?
- [ ] Class uses the correct namespace (e.g., `Event::ValidationTest`, `EventsController::IndexTest`)?
- [ ] Tests are independent (can run in isolation)?
- [ ] Uses fixtures instead of FactoryBot (unless there's a clear reason not to)?
- [ ] If FactoryBot is used, is it justified and uses only minimal necessary attributes?
- [ ] Test names are descriptive?
- [ ] Assertions are specific and clear?

## 8. Useful Commands

### Run all tests from a specific context

```bash
# All validation tests for Event
rails test test/models/event/validation_test.rb

# All index tests for EventsController
rails test test/controllers/events/index_test.rb

# All tests for a service
rails test test/services/events/soft_delete_test.rb
```

### Run a specific test

```bash
rails test test/models/event/validation_test.rb:5
```

### Run all tests from a directory

```bash
# All Event model tests
rails test test/models/event/

# All Events controller tests
rails test test/controllers/events/
```

## 9. Instructions for AI Agents

When an AI agent is asked to create or modify tests, follow this workflow:

### Before Writing Any Test

1. **Read this document completely** - Don't skip sections
2. **Identify the test type** - Model, Controller, Service, or other
3. **Check for existing fixtures** - Look in `test/fixtures/` for related data
4. **Determine the correct directory** - Follow the organization patterns in Section 2
5. **Choose the appropriate template** - Use templates from Section 6

### Decision Tree for Test Data

```
Need test data?
├─ Is this reference data (Countries, Tags, Roles)?
│  └─ YES → Use fixtures (they should already exist)
├─ Is this data reused across multiple tests?
│  └─ YES → Create/use fixtures
├─ Does the data need to be dynamic (random values, variable timestamps)?
│  └─ YES → Use FactoryBot (justified case)
└─ Default → Use fixtures
```

### Creating a New Test - Step by Step

1. **Locate the file**:
   - Models: `test/models/<model_name>/<context>_test.rb`
   - Controllers: `test/controllers/<controller_name>/<action>_test.rb`
   - Services: `test/services/<resource_plural>/<service_name>_test.rb`

2. **Create directories if needed**:
   ```bash
   mkdir -p test/models/event/
   ```

3. **Use the correct namespace**:
   - Models: `Event::ValidationTest`
   - Controllers: `EventsController::IndexTest`
   - Services: `Events::SoftDeleteTest`

4. **Prepare test data**:
   - First, check if fixtures exist: `test/fixtures/events.yml`
   - If they exist, use them: `events(:rails_conference)`
   - If they don't exist and data is reusable, create fixtures
   - Only use FactoryBot if data must be dynamic

5. **Write the test**

6. **Verify the test**:
   ```bash
   rails test test/path/to/your_test.rb
   ```

### Common Mistakes to Avoid

❌ **DON'T**:
- Use FactoryBot by default
- Create tests in the old monolithic structure (`test/models/event_test.rb`)
- Use generic test names like `test "should work"`
- Mix multiple responsibilities in one test file
- Use `create(:user)` when `users(:john)` fixture exists
- Forget to check if fixtures already exist

✅ **DO**:
- Check for existing fixtures first
- Create fixtures for reusable test data
- Use descriptive test names
- Follow the directory organization
- Use the correct namespace pattern
- Keep tests focused on one responsibility
- Run tests after creation to verify they work

### Example Workflow

**Task**: Create a test for Event model validation

1. **Check structure**: Need `test/models/event/validation_test.rb`
2. **Check fixtures**: Look at `test/fixtures/events.yml` and `test/fixtures/users.yml`
3. **Create test file**:
   ```ruby
   # test/models/event/validation_test.rb
   require "test_helper"

   class Event::ValidationTest < ActiveSupport::TestCase
     test "is valid with all required attributes" do
       event = events(:rails_conference)  # Using existing fixture
       assert event.valid?
     end

     test "is invalid without title" do
       event = events(:rails_conference)
       event.title = nil
       assert_not event.valid?
       assert_includes event.errors[:title], "can't be blank"
     end
   end
   ```
4. **Run test**: `rails test test/models/event/validation_test.rb`

## 10. Migrating Existing Tests

> **Note**: This document defines the standard for **new tests**. Existing tests will be migrated gradually as needed. When modifying an existing test, take the opportunity to migrate it to the new structure.

When migrating an existing test:

1. Identify the specific responsibility of the test
2. Create the appropriate directory if it doesn't exist
3. Create the new file with the correct namespace
4. Move only the tests related to that responsibility
5. Run the tests to ensure they continue working
6. Remove the tests from the original file only after the new one is working
