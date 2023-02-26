module Version
  def self.number
    file = File.read(Rails.root.join("package.json"))
    json = JSON.parse(file)

    json["version"]
  end
end
