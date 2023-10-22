class Backup
  class Db < Backup
    def call
      dump && upload
    end

    def dump
      @output_file = File.join(Rails.root, "tmp", "#{Date.today.strftime("%Y-%m-%d")}-#{ENV["DB_NAME"]}.backup")
      Rails.logger.info "Exportando base de dados #{ENV["DB_NAME"]} para #{@output_file}"

      command = <<~CMD
        PGPASSWORD=#{ENV["DB_PASSWORD"]} \
        /usr/bin/pg_dump \
        --username=#{ENV["DB_USERNAME"]} \
        --dbname=#{ENV["DB_NAME"]} \
        --host=#{ENV["DB_HOST"]} \
        --format custom \
        --file #{@output_file}
      CMD
      system(command)
    end

    def upload
      Rails.logger.info "Uploading #{@output_file} to OneDrive through Rclone"
      system("rclone move #{@output_file} onedrive:/db")
    end
  end
end
