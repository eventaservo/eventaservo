# frozen_string_literal: true

require "test_helper"

class ApplicationServiceTest < ActiveSupport::TestCase
  # Success tests
  test "success? is true when service succeeds" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1:, arg2:)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        success({arg1: @arg1, arg2: @arg2})
      end
    end

    service = some_service.call(arg1: "a", arg2: "b")
    assert service.success?
  end

  test "failure? is false when service succeeds" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1:, arg2:)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        success({arg1: @arg1, arg2: @arg2})
      end
    end

    service = some_service.call(arg1: "a", arg2: "b")
    assert_not service.failure?
  end

  test "payload is populated on success" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1:, arg2:)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        success({arg1: @arg1, arg2: @arg2})
      end
    end

    service = some_service.call(arg1: "a", arg2: "b")
    assert_equal({arg1: "a", arg2: "b"}, service.payload)
  end

  # Failure tests
  test "success? is false when service fails" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1, arg2)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        failure({error: "#{@arg1}, #{@arg2}"})
      end
    end

    service = some_service.call("a", "b")
    assert_not service.success?
  end

  test "failure? is true when service fails" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1, arg2)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        failure({error: "#{@arg1}, #{@arg2}"})
      end
    end

    service = some_service.call("a", "b")
    assert service.failure?
  end

  test "error is populated on failure" do
    some_service = Class.new(ApplicationService) do
      def initialize(arg1, arg2)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call
        failure({error: "#{@arg1}, #{@arg2}"})
      end
    end

    service = some_service.call("a", "b")
    assert_equal({error: "a, b"}, service.error)
  end
end
