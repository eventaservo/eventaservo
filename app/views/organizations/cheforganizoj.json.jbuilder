# frozen_string_literal: true

json.array!(@cheforganizoj) do |o|
  json.url organization_url(o.short_name)
  json.name o.name
  json.description o.description.to_plain_text.first(120) + "..."
  json.logo_url url_for(o.logo)
end
