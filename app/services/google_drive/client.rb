module GoogleDrive
  class Client
    require "google/apis/drive_v3"
    require "googleauth"
    require "googleauth/stores/file_token_store"

    def initialize
      @service = Google::Apis::DriveV3::DriveService.new
      @service.authorization = authorize
    end

    def upload_file(file_path)
      return false unless File.exist?(file_path)

      file_metadata = {
        name: File.basename(file_path),
        parents: [Rails.application.credentials.dig(:google_drive, :folder_id)]
      }

      result = @service.create_file(
        file_metadata,
        upload_source: file_path,
        content_type: "application/octet-stream"
      )

      result.id.present?
    end

    private

    def authorize
      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: Rails.application.credentials.dig(:google_drive, :client_id),
        client_secret: Rails.application.credentials.dig(:google_drive, :client_secret),
        scope: Google::Apis::DriveV3::AUTH_DRIVE_FILE,
        redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
      )

      credentials.refresh_token = Rails.application.credentials.dig(:google_drive, :refresh_token)
      credentials.fetch_access_token!
      credentials
    end
  end
end
