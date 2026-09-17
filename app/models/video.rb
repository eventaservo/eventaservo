# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id          :bigint           not null, primary key
#  description :string
#  title       :string
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#
class Video < ApplicationRecord
  has_one_attached :bildo

  validates_length_of :description, maximum: 400

  belongs_to :evento, class_name: "Event", foreign_key: "event_id"

  before_save :validas_ligilon
  after_save :save_thumbnail

  def youtube?
    url.include?("youtube.com") || url.include?("youtu.be")
  end

  def youtube_id
    return nil unless youtube?

    if url =~ %r{(youtu\.be/|youtube\.com/(watch\?v=|shorts/))([-\w]+)}
      $3
    end
  end

  # Searches videos by title or description using an accent-insensitive partial match.
  #
  # Spaces in the term are treated as wildcards.
  #
  # @param text [String, nil] the search term
  #
  # @return [ActiveRecord::Relation] the matching videos ordered by the most recent event first,
  #   or all videos when the term is blank
  def self.search(text)
    return all if text.blank?

    Video
      .joins(:evento)
      .where(
        "unaccent(videos.title) ilike unaccent(:search) OR unaccent(videos.description) ilike unaccent(:search)",
        search: "%#{text.strip.tr(" ", "%").downcase}%"
      ).order("events.date_start DESC")
  end

  private

  # Kontrolas ĉu la ligilo komencas per https
  def validas_ligilon
    self.url = if url[%r{\Ahttp://}] || url[%r{\Ahttps://}]
      url.strip
    else
      "https://#{url.strip}"
    end
  end

  def save_thumbnail
    return false unless youtube?
    return false unless saved_change_to_url?

    file = URI.open("https://i.ytimg.com/vi/#{youtube_id}/mqdefault.jpg")
    bildo.attach(io: file, filename: "bildo.jpg", content_type: "image/jpg")
  rescue => e
    Sentry.capture_exception(e)
  end
end
