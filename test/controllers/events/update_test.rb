# frozen_string_literal: true

require "test_helper"

# Integration tests for {EventsController#update}, focusing on file upload
# preservation across sequential submissions and authorization checks.
class EventsController::UpdateTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @owner = users(:user)
    @admin = users(:admin_user)
    @other_user = users(:teacher)
    @event = events(:valid_event)
  end

  # Success cases

  test "updates event attributes, tags, organizations, format, notifications, and audit log" do
    sign_in @owner
    org = organizations(:rotterdam_centre)
    category_tag = tags(:kurso)
    characteristic_tag = tags(:por_junuloj)

    assert_enqueued_with(job: EventoGhisdatigitaJob) do
      assert_difference ["Log.count", "Ahoy::Event.count"], 1 do
        patch event_path(code: @event.code), params: {
          event: {
            title: "Updated Web Event",
            description: @event.description,
            date_start: "2027-06-10",
            date_end: "2027-06-12",
            time_zone: "Etc/UTC",
            site: @event.site,
            email: @event.email,
            city: "Reta",
            country_id: 99_999,
            online: true
          },
          time_start: "09:00",
          time_end: "17:00",
          tags_categories: [category_tag.id.to_s],
          tags_characteristics: [characteristic_tag.id.to_s],
          organization_ids: [org.id.to_s]
        }
      end
    end

    assert_redirected_to event_path(code: @event.reload.ligilo)
    assert_equal I18n.t("flash.events.updated"), flash[:notice]
    assert_equal "Updated Web Event", @event.title
    assert_equal "online", @event.format
    assert_equal [org.id], @event.organizations.pluck(:id)
    assert_includes @event.tags, category_tag
    assert_includes @event.tags, characteristic_tag
  end

  test "uploading a second file via the event uploader form preserves existing uploads and tags" do
    sign_in @owner
    @event.tags = [tags(:kunveno_evento)]
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    get event_path(code: @event.ligilo)
    assert_response :success

    submit_params = extract_uploader_form_params
    submit_params[:event] = {
      uploads: [fixture_file_upload("printempas.jpg", "image/jpeg")]
    }

    patch event_path(code: @event.code), params: submit_params

    assert_redirected_to event_path(code: @event.ligilo)
    assert_equal I18n.t("flash.events.document_uploaded"), flash[:notice]

    @event.reload
    assert_equal ["jes.png", "printempas.jpg"], @event.uploads.order(:id).map { |upload| upload.filename.to_s }
    assert_includes @event.tags, tags(:kunveno_evento)
  end

  test "uploading a pdf document preserves existing photos" do
    sign_in @owner
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    get event_path(code: @event.ligilo)
    assert_response :success

    submit_params = extract_uploader_form_params
    submit_params[:event] = {
      uploads: [Rack::Test::UploadedFile.new(StringIO.new("%PDF-1.4\n"), "application/pdf", false, original_filename: "bulteno.pdf")]
    }

    patch event_path(code: @event.code), params: submit_params

    assert_redirected_to event_path(code: @event.ligilo)
    assert_equal I18n.t("flash.events.document_uploaded"), flash[:notice]

    @event.reload
    assert_equal ["jes.png", "bulteno.pdf"], @event.uploads.order(:id).map { |upload| upload.filename.to_s }
  end

  test "uploading files works regardless of active UI locale" do
    sign_in @admin
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    I18n.with_locale(:pt_BR) do
      get event_path(code: @event.ligilo, locale: :pt_BR)
      assert_response :success

      submit_params = extract_uploader_form_params
      submit_params[:event] = {
        uploads: [fixture_file_upload("printempas.jpg", "image/jpeg")]
      }

      patch event_path(code: @event.code, locale: :pt_BR), params: submit_params

      assert_redirected_to event_path(code: @event.ligilo, locale: :pt_BR)
      assert_equal I18n.t("flash.events.document_uploaded", locale: :pt_BR), flash[:notice]
    end

    assert_equal ["jes.png", "printempas.jpg"], @event.reload.uploads.order(:id).map { |upload| upload.filename.to_s }
  end

  test "legacy commit parameter Alŝuti still appends uploads without replacing existing ones" do
    sign_in @owner
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    patch event_path(code: @event.code), params: {
      commit: "Alŝuti",
      event: {
        uploads: [fixture_file_upload("printempas.jpg", "image/jpeg")]
      }
    }

    assert_redirected_to event_path(code: @event.ligilo)
    assert_equal I18n.t("flash.events.document_uploaded"), flash[:notice]
    assert_equal ["jes.png", "printempas.jpg"], @event.reload.uploads.order(:id).map { |upload| upload.filename.to_s }
  end

  # Error cases

  test "submitting uploader form without selecting a file shows error and preserves existing uploads" do
    sign_in @owner
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    get event_path(code: @event.ligilo)
    assert_response :success

    submit_params = extract_uploader_form_params
    submit_params[:event] = {uploads: [""]}

    patch event_path(code: @event.code), params: submit_params

    assert_redirected_to event_url(code: @event.ligilo)
    assert_equal I18n.t("flash.events.select_file_first"), flash[:error]
    assert_equal ["jes.png"], @event.reload.uploads.map { |upload| upload.filename.to_s }
  end

  test "uploading an invalid file format shows error and preserves existing uploads" do
    sign_in @owner
    @event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    get event_path(code: @event.ligilo)
    assert_response :success

    submit_params = extract_uploader_form_params
    submit_params[:event] = {
      uploads: [Rack::Test::UploadedFile.new(StringIO.new("plain text"), "text/plain", false, original_filename: "notes.txt")]
    }

    patch event_path(code: @event.code), params: submit_params

    assert_redirected_to event_path(code: @event.ligilo)
    assert_equal I18n.t("flash.events.invalid_file_format"), flash[:error]
    assert_equal ["jes.png"], @event.reload.uploads.map { |upload| upload.filename.to_s }
  end

  test "unauthenticated user cannot upload files" do
    patch event_path(code: @event.code), params: {
      file_upload: "1",
      event: {uploads: [fixture_file_upload("jes.png", "image/png")]}
    }

    assert_redirected_to new_user_session_path
    assert_not @event.reload.uploads.attached?
  end

  test "unauthorized user cannot upload files" do
    sign_in @other_user

    patch event_path(code: @event.code), params: {
      file_upload: "1",
      event: {uploads: [fixture_file_upload("jes.png", "image/png")]}
    }

    assert_redirected_to root_path
    assert_equal I18n.t("flash.general.unauthorized"), flash[:error]
    assert_not @event.reload.uploads.attached?
  end

  private

  # Extracts the non-file params that a browser submits from `#uploader_form`.
  #
  # @return [Hash{Symbol => String}] form parameters sent by the upload form
  def extract_uploader_form_params
    params = {}

    css_select("form#uploader_form input[type='hidden']").each do |input|
      name = input["name"]
      next if name.blank? || name.in?(%w[_method authenticity_token]) || name.end_with?("[]")

      params[name.to_sym] = input["value"].to_s
    end

    submit_button = css_select("form#uploader_form button[type='submit'], form#uploader_form input[type='submit']").first
    if submit_button && submit_button["name"].present?
      params[submit_button["name"].to_sym] = submit_button["value"].to_s
    end

    params
  end
end
