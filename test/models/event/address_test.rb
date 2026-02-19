# frozen_string_literal: true

require "test_helper"

class Event::AddressTest < ActiveSupport::TestCase
  test "full_address should not have leading comma if address is empty" do
    country = countries(:country_58)
    event = Event.new(address: "", city: "Parizo", country: country)
    assert_equal "Parizo, FR", event.full_address
  end

  test "full_address should not have extra commas if address is nil" do
    country = countries(:country_58)
    event = Event.new(address: nil, city: "Parizo", country: country)
    assert_equal "Parizo, FR", event.full_address
  end

  test "full_address should not have trailing commas if city or country are missing" do
    event = Event.new(address: "123 Strato", city: "", country: nil)
    assert_equal "123 Strato", event.full_address
  end

  test "full_address should handle all fields present" do
    country = countries(:country_58)
    event = Event.new(address: "123 Strato", city: "Parizo", country: country)
    assert_equal "123 Strato, Parizo, FR", event.full_address
  end

  test "full_address returns empty string for online events in Reta" do
    event = Event.new(online: true, city: "Reta")
    assert_equal "", event.full_address
  end
end
