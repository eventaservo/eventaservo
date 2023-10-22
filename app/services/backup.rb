class Backup
  def initialize
    setup_rclone
  end

  def setup_rclone
    access_token = Rails.application.credentials.dig(:rclone, :access_token)
    refresh_token = Rails.application.credentials.dig(:rclone, :refresh_token)
    root_folder_id = Rails.application.credentials.dig(:rclone, :root_folder_id)
    drive_id = Rails.application.credentials.dig(:rclone, :drive_id)

    rclone_config = <<~TEXT
      [onedrive]
      type = onedrive
      root_folder_id = #{root_folder_id}
      token = {"access_token":"#{access_token}","token_type":"Bearer","refresh_token":"#{refresh_token}","expiry":"2023-06-30T07:32:32.741424207-03:00"}
      drive_id = #{drive_id}
      drive_type = personal
    TEXT

    system("mkdir -p ~/.config/rclone")
    system("echo '#{rclone_config}' > ~/.config/rclone/rclone.conf")
  end
end
