module Backup
  class Db
    # Performs a database backup: runs pg_dump and uploads the result to Google Drive.
    #
    # @return [Boolean] true if both dump and upload succeed
    def call
      basename = "#{Date.today.strftime("%Y-%m-%d")}-#{ENV["DB_NAME"]}_#{Rails.env}"
      filename = "#{basename}.backup"

      Tempfile.create([basename, ".backup"]) do |tmpfile|
        dump(tmpfile.path) && upload(tmpfile.path, filename)
      end
    end

    private

    # Runs pg_dump command to create a custom-format dump file.
    #
    # @param output_path [String] path to write the dump file
    # @return [Boolean] true if pg_dump succeeds
    def dump(output_path)
      Rails.logger.info "Exporting database #{ENV["DB_NAME"]} to #{output_path}"

      env = {"PGPASSWORD" => ENV["DB_PASSWORD"]}
      command = [
        "/usr/bin/pg_dump",
        "--username=#{ENV["DB_USERNAME"]}",
        "--dbname=#{ENV["DB_NAME"]}",
        "--host=#{ENV["DB_HOST"]}",
        "--format=custom",
        "--file=#{output_path}"
      ]
      system(env, *command)
    end

    # Uploads a dump file to Google Drive.
    #
    # @param file_path [String] path to the dump file
    # @param filename [String] display name on Google Drive
    # @return [Boolean] true if upload succeeds
    def upload(file_path, filename)
      Rails.logger.info "Uploading #{filename} to Google Drive"
      client = ::GoogleDrive::Client.new
      client.upload_file(file_path, filename)
    end
  end
end
