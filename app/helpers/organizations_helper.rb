# frozen_string_literal: true

module OrganizationsHelper
  def organization_logo(organization, size: :small, html_class: nil)
    return unless organization.logo.attached?

    size =
      case size
      when :large then '128x128'
      when :medium then '48x48'
      else '20x20'
      end

    image_tag organization.logo.variant(resize: size), width: size, class: html_class
  end

  # Montras la organizojn pri la evento
  # @param [Object] event
  # @param [FalseClass] limited
  def display_organizations_for_event(event, limited: false)
    content_tag(:div, class: 'organization-tags') do
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
    link_to organization_url(organization.short_name), class: 'tag' do
      content_tag(:div, organization.short_name)
    end
  end

  def display_event_tags(event)
    content_tag(:div, class: 'event-tags') do
      event.specoj.each do |t|
        concat content_tag(:span, t, class: 'badge badge-pill badge-info mr-1')
      end
    end
  end

  def display_event_days_left(event)
    days = event.tagoj[:restanta]
    case days
    when (Float::INFINITY * -1)..0
      ''
    when 1
      '| finiĝos morgaŭ'
    else
      "| finiĝos post #{days} tagoj"
    end
  end
end
