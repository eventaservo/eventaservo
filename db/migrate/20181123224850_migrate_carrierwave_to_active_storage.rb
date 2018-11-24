class MigrateCarrierwaveToActiveStorage < ActiveRecord::Migration[5.2]
  def up
    User.where.not(avatar: nil).each do |user|
      user.picture.attach(io: File.open(user.avatar.path), filename: user.avatar.file.filename, content_type: user.avatar.file.content_type)
    end

    Event.all.each do |event|
      unless event.attachments.empty?
        event.attachments.all.each do |attachment|
          event.uploads.attach(io: File.open(attachment.file.path), filename: attachment.file_name, content_type: attachment.content_type)
        end
      end
    end
  end

  def down
    ActiveStorage::Attachment.all.each(&:purge)
  end
end
