# frozen_string_literal: true

module OrganizationsHelper
  def organization_logo(organization, size: :small, html_class: nil)
    return unless organization.logo.attached?

    size =
      case size
      when :large then [128, 128]
      when :medium then [48, 48]
      else [20, 20]
      end

    image_tag organization.logo.variant(resize_to_limit: size), width: size, class: html_class
  end

  # Montras la organizojn pri la evento
  # @param [Object] event
  # @param [FalseClass] limited
  def display_organizations_for_event(event, limited: false)
    content_tag(:div, class: "organization-tags") do
      if limited && event.organizations.count > 1
        concat organization_tag(event.organizations.first) + " +#{event.organizations.count - 1}"
      else
        event.organizations.each do |organization|
          concat organization_tag(organization)
        end
      end
    end
  end

  def organization_tag(organization)
    link_to organization_url(organization.short_name), class: "tag" do
      content_tag(:div, organization.short_name)
    end
  end

  def display_event_tags(event)
    content_tag(:div, class: "event-tags") do
      event.tags.each do |tag|
        tag_color =
          if tag.category?
            "badge-info"
          elsif tag.characteristic?
            "badge-warning"
          else
            "badge-danger"
          end
        concat content_tag(:span, tag.name, class: "mr-1 badge badge-pill #{tag_color}")
      end
    end
  end

  def display_event_days_left(event)
    days = event.tagoj[:restanta]
    case days
    when (Float::INFINITY * -1)..0
      ""
    when 1
      "| finiĝos morgaŭ"
    else
      "| finiĝos post #{days} tagoj"
    end
  end
end
