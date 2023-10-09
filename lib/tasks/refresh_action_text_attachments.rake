namespace :action_text do
  desc "Refresh action text attachments"
  task refresh_attachments: :environment do
    def refresh_trix(trix)
      return unless trix.embeds.size.positive?

      trix.body.fragment.find_all("action-text-attachment").each do |node|
        embed = trix.embeds.find do |attachment|
          attachment.filename.to_s == node["filename"] && attachment.byte_size.to_s == node["filesize"]
        end

        node.attributes["url"].value = Rails.application.routes.url_helpers.rails_storage_redirect_url(embed.blob)
        node.attributes["sgid"].value = embed.attachable_sgid
      end

      trix.update_column :body, trix.body.to_s
    end

    ActionText::RichText.where.not(body: nil).find_each do |trix|
      print "Processing ActionText::RichText #{trix.id}  \r"
      refresh_trix(trix)
    rescue => e
      puts "ActionText::RichText #{trix.id}: #{e.message}"
      next
    end
  end
end
