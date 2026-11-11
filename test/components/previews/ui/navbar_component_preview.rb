# frozen_string_literal: true

# Previews the Tailwind-based Ui::NavbarComponent across states, proposals, and viewports.
class Ui::NavbarComponentPreview < ViewComponent::Preview
  # Default public navigation bar with search and visitor links.
  #
  # @param title text "Brand title"
  # @param env_badge text "Environment indicator"
  #
  # @return [String] rendered component
  def default(title: "Eventa Servo", env_badge: "")
    render_with_template(locals: {title:, env_badge:})
  end

  # Demonstrates navigation bar with an authenticated user (clean avatar, no badges).
  #
  # @return [String]
  def logged_in
    render_with_template
  end

  # Proposal A: Action-First Navigation (desktop view).
  #
  # @return [String]
  def proposal_a_actions
    render_with_template
  end

  # Proposal A in Mobile View (smartphone frame at 375px).
  #
  # @return [String]
  def proposal_a_mobile
    render_with_template
  end

  # Proposal B: Minimalist & Icon-Driven (desktop view).
  #
  # @return [String]
  def proposal_b_minimalist
    render_with_template
  end

  # Proposal B in Mobile View (smartphone frame at 375px).
  #
  # @return [String]
  def proposal_b_mobile
    render_with_template
  end

  # Proposal C: Capsule & Airbnb-Inspired (desktop view).
  #
  # @return [String]
  def proposal_c_airbnb
    render_with_template
  end

  # Proposal C in Mobile View (smartphone frame at 375px).
  #
  # @return [String]
  def proposal_c_mobile
    render_with_template
  end

  # Compares all 3 proposals side by side in realistic smartphone frames.
  #
  # @return [String]
  def all_proposals_mobile
    render_with_template
  end

  # Demonstrates navigation bar with active tools (Map, Telegram, About).
  #
  # @return [String]
  def with_active_tools
    render_with_template
  end

  # Demonstrates navigation bar on narrow mobile viewports.
  #
  # @return [String]
  def mobile_view
    render_with_template
  end
end
