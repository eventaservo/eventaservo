module Version
  def self.number
    File.read(Rails.root.join("version"))
  end
end
