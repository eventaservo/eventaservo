# frozen_string_literal: true

require 'test_helper'

class OrganizationsHelperTest < ActionView::TestCase
  include OrganizationsHelper

  test 'display_event_tags returns correct bootstrap 5 classes' do
    country = Country.first || Country.create!(name: 'Test', code: 'TS', continent: 'Europe')
    user = User.first || User.create!(email: "test#{rand(1000)}@example.com", password: 'password', username: "testuser#{rand(1000)}")
    
    event = Event.create!(
      title: 'Test Event', 
      description: 'Test Description',
      city: 'Test City',
      country: country,
      user: user,
      date_start: Time.zone.now,
      date_end: Time.zone.now + 1.hour,
      code: "TEST#{rand(1000)}",
      site: 'https://eventaservo.org'
    )
    
    category_tag = Tag.find_or_create_by!(name: 'Kategorio', group_name: 'category')
    characteristic_tag = Tag.find_or_create_by!(name: 'Karakterizo', group_name: 'characteristic')
    
    event.tags << category_tag
    event.tags << characteristic_tag

    result = display_event_tags(event)

    assert_match(/text-bg-info/, result)
    assert_match(/text-bg-warning/, result)
    assert_match(/badge rounded-pill/, result)
  end
end
