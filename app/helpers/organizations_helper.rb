# frozen_string_literal: true

# Helper methods for rendering organization badges, logos, and event days countdown.
module OrganizationsHelper
  # Renders the logo image for an organization if attached.
  #
  # @param organization [Organization] the organization whose logo to render
  # @param size [Symbol] image size variant (:small, :medium, :large)
  # @param html_class [String, nil] additional CSS classes for the image tag
  #
  # @return [ActiveSupport::SafeBuffer, nil] the image tag, or nil if logo is not attached
  def organization_logo(organization, size: :small, html_class: nil)
    return unless organization.persisted? && organization.logo.attached?

    size =
      case size
      when :large then [128, 128]
      when :medium then [48, 48]
      else [20, 20]
      end

    image_tag organization.logo.variant(resize_to_limit: size), width: size, class: html_class
  end

  # Renders the event's organizations as tag links, optionally limiting the
  # output to a single organization plus a "+N" counter.
  #
  # Uses +size+ (memory-aware when the association is loaded) instead of
  # +count+ so that preloaded associations do not trigger extra COUNT(*)
  # queries per event (N+1).
  #
  # @param event [Event] the event whose organizations to display
  # @param limited [Boolean] when true and the event has more than one
  #   organization, render only the first organization plus a "+N" counter
  #
  # @return [ActiveSupport::SafeBuffer] the rendered organization tags
  def display_organizations_for_event(event, limited: false)
    content_tag(:div, class: "organization-tags") do
      organizations = event.organizations
      if limited && organizations.size > 1
        concat organization_tag(organizations.first) + " +#{organizations.size - 1}"
      else
        organizations.each do |organization|
          concat organization_tag(organization)
        end
      end
    end
  end

  # Renders a linked tag badge for an organization.
  #
  # @param organization [Organization] the organization to link to
  #
  # @return [ActiveSupport::SafeBuffer] the rendered organization link
  def organization_tag(organization)
    link_to organization_url(organization.short_name), class: "tag" do
      content_tag(:div, organization.short_name)
    end
  end

  # Renders category and characteristic badges for an event.
  #
  # @param event [Event] the event whose tags to display
  #
  # @return [ActiveSupport::SafeBuffer] the rendered tag badges container
  def display_event_tags(event)
    content_tag(:div, class: "event-tags") do
      tags = if event.tags.loaded?
        event.tags.sort_by { |t| [t.group_name.to_s, t.sort_order.to_i] }
      else
        event.tags.order(:group_name, :sort_order)
      end

      tags.each do |tag|
        next unless tag.category? || tag.characteristic?

        tag_color =
          if tag.category?
            "text-bg-info"
          elsif tag.characteristic?
            "text-bg-warning"
          end
        concat content_tag(:span, tag.name, class: "me-1 badge rounded-pill #{tag_color}")
      end
    end
  end

  # Renders remaining days text for an event.
  #
  # @param event [Event] the event to display remaining days for
  #
  # @return [String] formatted string indicating days left, or empty string if passed
  def display_event_days_left(event)
    days = event.days_progress[:remaining]
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
