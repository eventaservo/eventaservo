---
name: test-builder
description: Create tests following project architecture guidelines. Use when creating tests for models, controllers, services, or any component. Triggers on keywords like "test", "teste", "spec", "create test", "add test", "test coverage".
---

# Test Builder Skill

This skill creates consistent tests following the project's test architecture defined in [TEST_ARCHITECTURE.md](/eventaservo/TEST_ARCHITECTURE.md).

## When to Use

- Creating tests for new features (models, controllers, services)
- Adding test coverage for existing code
- When explicitly asked to create or modify tests
- After implementing new functionality that needs testing

## Critical Rules

**MUST READ FIRST**: Before creating any test, consult [TEST_ARCHITECTURE.md](/eventaservo/TEST_ARCHITECTURE.md) Section 9 (Instructions for AI Agents).

### 1. Test Data Strategy

**Default: Use Fixtures**

```ruby
# ✅ GOOD - Using fixtures
test "user must have a valid country" do
  user = users(:john)
  assert user.valid?
end

# ❌ BAD - Using FactoryBot unnecessarily
test "user must have a valid country" do
  user = create(:user, country: create(:country))
  assert user.valid?
end
```

**Only use FactoryBot when**:
- Data must be truly dynamic (random values, variable timestamps)
- Testing data variability specifically
- Fixtures are impractical for the specific case

### 2. Directory Organization

**Models**: `test/models/<model_name>/<context>_test.rb`
```
test/models/event/
├── validation_test.rb
├── association_test.rb
├── scope_test.rb
└── method_test.rb
```

**Controllers**: `test/controllers/<controller_name>/<action>_test.rb`
```
test/controllers/events/
├── index_test.rb
├── show_test.rb
├── create_test.rb
└── update_test.rb
```

**Services**: `test/services/<resource_plural>/<service_name>_test.rb`
```
test/services/events/
├── soft_delete_test.rb
└── schedule_reminders_test.rb
```

### 3. Namespace Conventions

```ruby
# Models
class Event::ValidationTest < ActiveSupport::TestCase

# Controllers
class EventsController::IndexTest < ActionDispatch::IntegrationTest

# Services
class Events::SoftDeleteTest < ActiveSupport::TestCase
```

## Workflow

### Step 1: Check for Existing Fixtures

Before writing any test, check if fixtures exist:

```bash
# Check fixtures directory
ls test/fixtures/
```

Look for relevant fixture files:
- `users.yml` - User fixtures
- `events.yml` - Event fixtures
- `countries.yml` - Country reference data
- etc.

### Step 2: Determine Test Location

Based on what you're testing:
- **Model validations** → `test/models/<model>/validation_test.rb`
- **Model associations** → `test/models/<model>/association_test.rb`
- **Model scopes** → `test/models/<model>/scope_test.rb`
- **Controller action** → `test/controllers/<controller>/<action>_test.rb`
- **Service** → `test/services/<resource_plural>/<service_name>_test.rb`

### Step 3: Create Directory Structure

```bash
# For models
mkdir -p test/models/event

# For controllers
mkdir -p test/controllers/events

# For services
mkdir -p test/services/events
```

### Step 4: Write the Test

Use the appropriate template from TEST_ARCHITECTURE.md Section 6.

**Model Test Template**:
```ruby
# test/models/event/validation_test.rb
require "test_helper"

class Event::ValidationTest < ActiveSupport::TestCase
  test "is valid with all required attributes" do
    event = events(:rails_conference)

    assert event.valid?
  end

  test "is invalid without title" do
    event = events(:rails_conference)
    event.title = nil

    result = event.valid?

    assert_not result
    assert_includes event.errors[:title], "can't be blank"
  end
end
```

**Controller Test Template**:
```ruby
# test/controllers/events/index_test.rb
require "test_helper"

class EventsController::IndexTest < ActionDispatch::IntegrationTest
  test "returns successful response" do
    user = users(:john)
    sign_in user

    get events_url

    assert_response :success
  end

  test "displays all published events" do
    get events_url

    assert_select "h2", events(:rails_conference).title
  end
end
```

**Service Test Template**:
```ruby
# test/services/events/soft_delete_test.rb
require "test_helper"

class Events::SoftDeleteTest < ActiveSupport::TestCase
  test "marks event as deleted" do
    event = events(:rails_conference)

    result = Events::SoftDelete.call(event)

    assert result.success?
    assert event.reload.deleted?
  end

  test "fails when event is already deleted" do
    event = events(:deleted_event)

    result = Events::SoftDelete.call(event)

    assert result.failure?
    assert_includes result.error, "already deleted"
  end
end
```

### Step 5: Verify the Test

```bash
# Run the specific test file
rails test test/models/event/validation_test.rb

# Run a specific test
rails test test/models/event/validation_test.rb:10

# Run all tests for a model
rails test test/models/event/
```

## Common Patterns

### Testing Validations

```ruby
test "validates presence of required fields" do
  event = Event.new
  assert_not event.valid?
  assert_includes event.errors[:title], "can't be blank"
  assert_includes event.errors[:user], "must exist"
end

test "validates length of title" do
  event = events(:rails_conference)
  event.title = "a" * 256
  assert_not event.valid?
  assert_includes event.errors[:title], "too long"
end
```

### Testing Associations

```ruby
test "belongs to user" do
  event = events(:rails_conference)
  assert_equal users(:john), event.user
end

test "has many participants" do
  event = events(:rails_conference)
  assert_equal 3, event.participants.count
end
```

### Testing Scopes

```ruby
test "published scope returns only published events" do
  published_count = Event.published.count
  assert_equal 2, published_count
end

test "upcoming scope returns future events" do
  upcoming = Event.upcoming
  assert upcoming.all? { |e| e.starts_at > Time.current }
end
```

### Testing Controller Actions

```ruby
test "creates event with valid params" do
  user = users(:john)
  sign_in user

  assert_difference "Event.count", 1 do
    post events_url, params: {
      event: {
        title: "New Event",
        starts_at: 1.day.from_now,
        ends_at: 2.days.from_now
      }
    }
  end

  assert_redirected_to event_path(Event.last)
end

test "does not create event with invalid params" do
  user = users(:john)
  sign_in user

  assert_no_difference "Event.count" do
    post events_url, params: { event: { title: "" } }
  end

  assert_response :unprocessable_entity
end
```

## Anti-Patterns to Avoid

### ❌ Don't Use FactoryBot by Default

```ruby
# BAD
test "user is valid" do
  user = create(:user)
  assert user.valid?
end

# GOOD
test "user is valid" do
  user = users(:john)
  assert user.valid?
end
```

### ❌ Don't Create Monolithic Test Files

```ruby
# BAD - Everything in one file
# test/models/event_test.rb (500 lines)
class EventTest < ActiveSupport::TestCase
  # validations, associations, scopes, methods all mixed
end

# GOOD - Separated by responsibility
# test/models/event/validation_test.rb
# test/models/event/association_test.rb
# test/models/event/scope_test.rb
```

### ❌ Don't Use Generic Test Names

```ruby
# BAD
test "should work"
test "title"

# GOOD
test "validates presence of title"
test "returns only published events"
```

### ❌ Don't Forget Fixtures

```ruby
# BAD - Creating data when fixtures exist
test "event has user" do
  user = create(:user)
  event = create(:event, user: user)
  assert_equal user, event.user
end

# GOOD - Using existing fixtures
test "event has user" do
  event = events(:rails_conference)
  assert_equal users(:john), event.user
end
```

## Checklist

Before submitting a test, verify:

- [ ] Checked for existing fixtures first
- [ ] Used fixtures instead of FactoryBot (unless justified)
- [ ] File is in correct directory structure
- [ ] Class uses correct namespace
- [ ] Test names are descriptive
- [ ] Tests are independent (can run in isolation)
- [ ] Test passes when run individually
- [ ] Test passes when run with full suite

## Reference

For complete guidelines and detailed examples, always refer to:
- [TEST_ARCHITECTURE.md](/eventaservo/TEST_ARCHITECTURE.md) - Complete test architecture guide
- [AGENTS.md](/eventaservo/AGENTS.md) - General project guidelines

## Quick Commands

```bash
# Run single test file
rails test test/models/event/validation_test.rb

# Run specific test by line number
rails test test/models/event/validation_test.rb:10

# Run all tests in directory
rails test test/models/event/

# Run all tests
rails test
```
