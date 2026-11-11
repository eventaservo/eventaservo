# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::AlertComponent.
  class AlertComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders standard banner with text parameter" do
      render_inline(Ui::AlertComponent.new("Grava informo"))

      assert_selector "div[role='status']", text: "Grava informo"
      assert_selector "div.tw\\:bg-\\[\\#d1ecf1\\].tw\\:border-\\[\\#a2d9e2\\].tw\\:text-\\[\\#09414a\\]"
      assert_selector "div.tw\\:py-2.tw\\:px-3.tw\\:text-sm"
    end

    test "renders banner with block content" do
      render_inline(Ui::AlertComponent.new) { "Bloka Enhavo" }

      assert_selector "div[role='status']", text: "Bloka Enhavo"
    end

    test "renders contextual color variants matching Bootstrap 5.3 1:1" do
      # Info (default)
      render_inline(Ui::AlertComponent.new("Info", variant: :info))
      assert_selector "div.tw\\:bg-\\[\\#d1ecf1\\].tw\\:border-\\[\\#a2d9e2\\].tw\\:text-\\[\\#09414a\\]"

      # Primary / Notice
      render_inline(Ui::AlertComponent.new("Notice", variant: :notice))
      assert_selector "div.tw\\:bg-\\[\\#cfe2ff\\].tw\\:border-\\[\\#9ec5fe\\].tw\\:text-\\[\\#0a58ca\\]"

      # Success
      render_inline(Ui::AlertComponent.new("Success", variant: :success))
      assert_selector "div.tw\\:bg-\\[\\#d4edd9\\].tw\\:border-\\[\\#a9dbb4\\].tw\\:text-\\[\\#10431c\\]"

      # Warning
      render_inline(Ui::AlertComponent.new("Warning", variant: :warning))
      assert_selector "div.tw\\:bg-\\[\\#fff3cd\\].tw\\:border-\\[\\#ffe69c\\].tw\\:text-\\[\\#664d03\\]"

      # Danger / Error
      render_inline(Ui::AlertComponent.new("Danger", variant: :danger))
      assert_selector "div.tw\\:bg-\\[\\#f8d7da\\].tw\\:border-\\[\\#f1aeb4\\].tw\\:text-\\[\\#58151c\\]"

      # Secondary
      render_inline(Ui::AlertComponent.new("Secondary", variant: :secondary))
      assert_selector "div.tw\\:bg-\\[\\#e2e3e5\\].tw\\:border-\\[\\#c4c7cb\\].tw\\:text-\\[\\#2b2f33\\]"

      # Light
      render_inline(Ui::AlertComponent.new("Light", variant: :light))
      assert_selector "div.tw\\:bg-\\[\\#fcfcfc\\].tw\\:border-\\[\\#e9ecef\\].tw\\:text-\\[\\#495057\\]"
    end

    test "maps Rails flash key alert to warning variant" do
      render_inline(Ui::AlertComponent.new("Averto", variant: :alert))

      assert_selector "div.tw\\:bg-\\[\\#fff3cd\\].tw\\:border-\\[\\#ffe69c\\].tw\\:text-\\[\\#664d03\\]"
    end

    test "sets assertive aria-live on danger/error and polite on others" do
      render_inline(Ui::AlertComponent.new("Eraro", variant: :danger))
      assert_selector "div[aria-live='assertive']"

      render_inline(Ui::AlertComponent.new("Informo", variant: :info))
      assert_selector "div[aria-live='polite']"
    end

    test "renders sizes medium (default) and large" do
      # Medium is system default
      render_inline(Ui::AlertComponent.new("Meza"))
      assert_selector "div.tw\\:py-2.tw\\:px-3.tw\\:text-sm"

      # Large
      render_inline(Ui::AlertComponent.new("Granda", size: :large))
      assert_selector "div.tw\\:py-3\\.5.tw\\:px-4.tw\\:text-base"

      # Aliases map properly
      render_inline(Ui::AlertComponent.new("Alias", size: :small))
      assert_selector "div.tw\\:py-2.tw\\:px-3.tw\\:text-sm"
    end

    test "renders title when provided" do
      render_inline(Ui::AlertComponent.new("Enhavo", title: "Grava Titolo"))

      assert_selector "h5", text: "Grava Titolo"
    end

    test "renders contextual icon when icon is true" do
      render_inline(Ui::AlertComponent.new("Sukceso", variant: :success, icon: true))

      assert_selector "i.fas.fa-check-circle"
    end

    test "renders custom icon when string is provided" do
      render_inline(Ui::AlertComponent.new("Sciigo", icon: "bell"))

      assert_selector "i.fas.fa-bell"
    end

    test "renders dismissible close button with Stimulus controller and no border" do
      render_inline(Ui::AlertComponent.new("Fermebla", dismissible: true))

      assert_selector "div[data-controller='dismissible']"
      assert_selector "button[data-action='dismissible#dismiss']"
      assert_selector "button.tw\\:border-0.tw\\:bg-transparent"
      assert_selector "button i.fa-times"
    end

    test "renders top-floating flash banner mode" do
      render_inline(Ui::AlertComponent.new("Flash mesaĝo", flash: true))

      assert_selector "div.flash-alert-box"
      assert_selector "div.tw\\:fixed.tw\\:top-10"
      assert_selector "div[data-controller='dismissible']"
      assert_selector "div[data-dismissible-auto-dismiss-value='5000']"
      assert_selector "button[data-action='dismissible#dismiss']"
    end

    test "merges custom html attributes and classes" do
      render_inline(Ui::AlertComponent.new("Propra", class: "custom-class", id: "my-alert"))

      assert_selector "div#my-alert.custom-class"
    end
  end
end
