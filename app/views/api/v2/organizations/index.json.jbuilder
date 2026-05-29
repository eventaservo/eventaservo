json.count @organizations.count

json.organizations do
  json.array!(@organizations) do |org|
    json.name org.name
    json.short_name org.short_name
    json.address org.address
    json.city org.city
    json.country org.country&.name
    json.country_code org.country&.code

    json.contact do
      json.email org.email
      json.phone org.phone
      json.url org.url
      json.youtube org.youtube
    end

    json.updated_at org.updated_at
  end
end
