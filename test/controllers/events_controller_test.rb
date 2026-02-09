# frozen_string_literal: true

require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  # Empty parent class - tests are in nested classes to avoid inheritance issues

  # GET #index tests
  class IndexTest < EventsControllerTest
    test "index requires authentication" do
      get events_path
      assert_redirected_to new_user_session_path
    end
  end

  # GET #show tests
  class ShowTest < EventsControllerTest
    test "show returns http success" do
      event = create(:event)
      get event_path(code: event.code)
      assert_response :success
    end

    test "show redirects to home page when event doesn't exist" do
      event = create(:event)
      event.destroy

      get event_path(code: event.code)
      assert_redirected_to root_path
    end
  end

  # GET #new tests
  class NewTest < EventsControllerTest
    test "new requires authentication" do
      get new_event_path
      assert_redirected_to new_user_session_path
    end

    test "new returns http success" do
      user = create(:user)
      sign_in user
      get new_event_path
      assert_response :success
    end
  end

  # GET #kronologio tests
  class KronologioTest < EventsControllerTest
    test "kronologio returns http success" do
      event = create(:event, :minimal)
      get event_kronologio_path(event_code: event.code)
      assert_response :success
    end

    test "kronologio redirects to home page when event doesn't exist" do
      event = create(:event)
      event.destroy

      get event_kronologio_path(event_code: event.code)
      assert_redirected_to root_path
    end
  end

  # DELETE #destroy tests
  class DestroyTest < EventsControllerTest
    setup do
      @user = create(:user)
      @event = create(:event, user: @user)
      sign_in @user
    end

    test "calls the SoftDelete service with correct parameters" do
      service_instance = Minitest::Mock.new
      service_instance.expect(:success?, true)

      Events::SoftDelete.stub(:call, service_instance) do
        delete event_path(code: @event.code)
      end

      assert service_instance.verify
    end

    test "redirects to root path with notice when service returns success" do
      service_instance = Minitest::Mock.new
      service_instance.expect(:success?, true)

      Events::SoftDelete.stub(:call, service_instance) do
        delete event_path(code: @event.code)
        assert_redirected_to root_url
        assert_not_nil flash[:notice]
      end
    end

    test "redirects to event path with error when service returns failure" do
      error_message = "User is not authorized to delete event"
      service_instance = Minitest::Mock.new
      service_instance.expect(:success?, false)
      service_instance.expect(:error, error_message)

      Events::SoftDelete.stub(:call, service_instance) do
        delete event_path(code: @event.code)
        assert_redirected_to event_path(code: @event.ligilo)
        assert_equal error_message, flash[:error]
      end
    end

    test "requires authentication when user is not signed in" do
      sign_out @user

      delete event_path(code: @event.code)
      assert_redirected_to new_user_session_path
    end
  end
end
