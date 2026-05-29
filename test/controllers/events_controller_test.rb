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

  # POST #nuligi tests
  class NuligiTest < EventsControllerTest
    setup do
      @user = create(:user)
      @event = create(:event, user: @user)
    end

    test "cancels the event with a reason" do
      sign_in @user
      reason = "Weather conditions"
      post event_nuligi_path(event_code: @event.code), params: {cancel_reason: reason}

      assert_redirected_to event_path(code: @event.code)
      assert_equal "Evento nuligita", flash[:notice]

      @event.reload
      assert @event.cancelled?
      assert_equal reason, @event.cancel_reason
    end

    test "cancels the event with tracking" do
      sign_in @user
      reason = "Weather conditions"
      assert_difference("Ahoy::Event.count", 1) do
        post event_nuligi_path(event_code: @event.code), params: {cancel_reason: reason}
      end

      assert_redirected_to event_path(code: @event.code)
    end

    test "cancels the event using short_url" do
      sign_in @user
      reason = "Weather conditions"
      post event_nuligi_path(event_code: @event.short_url), params: {cancel_reason: reason}

      assert_redirected_to event_path(code: @event.short_url)
      @event.reload
      assert @event.cancelled?
      assert_equal reason, @event.cancel_reason
    end

    test "nuligi requires authentication" do
      post event_nuligi_path(event_code: @event.code)
      assert_redirected_to new_user_session_path
    end

    test "nuligi requires authorization" do
      other_user = create(:user)
      sign_in other_user
      post event_nuligi_path(event_code: @event.code)
      assert_redirected_to root_url
      assert_equal "Vi ne rajtas", flash[:error]
    end
  end

  # GET #malnuligi tests
  class MalnuligiTest < EventsControllerTest
    setup do
      @user = create(:user)
      @event = create(:event, user: @user, cancelled: true, cancel_reason: "Weather conditions")
    end

    test "uncancels the event and clears the reason" do
      sign_in @user
      get event_malnuligi_path(event_code: @event.code)

      assert_redirected_to event_path(code: @event.code)
      assert_equal "Evento malnuligita", flash[:notice]

      @event.reload
      assert_not @event.cancelled?
      assert_nil @event.cancel_reason
    end

    test "uncancels the event with tracking" do
      sign_in @user
      assert_difference("Ahoy::Event.count", 1) do
        get event_malnuligi_path(event_code: @event.code)
      end

      assert_redirected_to event_path(code: @event.code)
    end

    test "malnuligi requires authentication" do
      get event_malnuligi_path(event_code: @event.code)
      assert_redirected_to new_user_session_path
    end

    test "malnuligi requires authorization" do
      other_user = create(:user)
      sign_in other_user
      get event_malnuligi_path(event_code: @event.code)
      assert_redirected_to root_url
      assert_equal "Vi ne rajtas", flash[:error]
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

  # POST #kontakti_organizanton tests
  class KontaktiOrganizantonTest < EventsControllerTest
    setup do
      @user = create(:user)
      @event = create(:event)
      sign_in @user
    end

    test "successfully sends a message to the organizer" do
      message = "Saluton, mi havas demandojn."
      assert_enqueued_emails 1 do
        post event_kontakti_organizanton_path(event_code: @event.code), params: {message: message}
      end

      assert_redirected_to event_url(code: @event.code)
      assert_equal "Mesaĝo sendita", flash[:info]
    end

    test "kontakti_organizanton requires authentication" do
      sign_out @user
      post event_kontakti_organizanton_path(event_code: @event.code)
      assert_redirected_to new_user_session_path
    end
  end

  # DELETE #delete_file tests
  class DeleteFileTest < EventsControllerTest
    setup do
      @user = create(:user)
      @event = create(:event, user: @user)
    end

    test "successfully deletes a file" do
      sign_in @user
      @event.uploads.attach(
        io: File.open(Rails.root.join("test", "fixtures", "files", "jes.png")),
        filename: "jes.png",
        content_type: "image/png"
      )
      upload = @event.uploads.last

      assert_difference("@event.uploads.count", -1) do
        delete event_delete_file_path(event_code: @event.code, file_id: upload.id)
      end

      assert_redirected_to event_path(code: @event.ligilo)
      assert_equal "Dosiero sukcese forigita", flash[:success]
    end

    test "delete_file requires authentication" do
      delete event_delete_file_path(event_code: @event.code, file_id: 1)
      assert_redirected_to new_user_session_path
    end

    test "delete_file requires authorization" do
      other_user = create(:user)
      sign_in other_user
      delete event_delete_file_path(event_code: @event.code, file_id: 1)
      assert_redirected_to root_url
      assert_equal "Vi ne rajtas", flash[:error]
    end
  end
end
