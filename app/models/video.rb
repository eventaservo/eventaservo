class Video < ApplicationRecord

  has_one_attached :bildo

  validates_length_of :description, maximum: 400

  belongs_to :evento, class_name: 'Event', foreign_key: 'event_id'

  before_save :validas_ligilon
  after_save :elshultas_bildon

  def youtube?
    url.include?("youtube.com") || url.include?("youtu.be")
  end

  def youtube_id
    return nil unless youtube?

    regex =  Regexp.new(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/)
    url[regex,1]
  end

  def self.serchi(teksto)
    Video
      .joins(:evento)
      .where(
        "unaccent(videos.title) ilike unaccent(:search) OR unaccent(videos.description) ilike unaccent(:search)",
        search: "%#{teksto.strip.tr(' ', '%').downcase}%"
      ).order("events.date_start DESC")
  end

  private

  # Kontrolas ĉu la ligilo komencas per https
  def validas_ligilon
    if url[%r{\Ahttp:\/\/}] || url[%r{\Ahttps:\/\/}]
      self.url = url.strip
    else
      self.url = "https://#{url.strip}"
    end
  end

  def elshultas_bildon
    return false unless youtube?
    return false unless saved_change_to_url?

    file = URI.open("https://i.ytimg.com/vi/#{self.youtube_id}/mqdefault.jpg")
    self.bildo.attach(io: file, filename: 'bildo.jpg', content_type: 'image/jpg')
  end
end
