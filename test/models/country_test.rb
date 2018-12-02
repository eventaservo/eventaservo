# frozen_string_literal: true

require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  test 'devas fiaski se ne havas land-nomo' do
    country = Country.new
    assert_not country.valid?
  end

  test 'devas sukcesi se havas nomon' do
    country = Country.new(name: 'Prov-lando')
    assert country.valid?
  end

  test 'fiaskas se lando jam ekzistas' do
    landnomo = 'Prov-lando'
    Country.create!(name: landnomo)
    new_country = Country.new(name: landnomo)
    assert_not new_country.valid?
  end

  test 'lando havas recipients' do
    assert_not_nil Country.reflect_on_association(:recipients)

    recipient = notification_list(:one)
    country = countries(:one)
    recipient.update_attribute(:country_id, country.id)

    assert country.recipients.find_by(id: recipient.id).present?
  end

  test 'lando havas uzantoj' do
    assert_not_nil Country.reflect_on_association(:users)

    user    = users(:one)
    country = countries(:one)
    user.update_attribute(:country_id, country.id)

    assert country.users.find_by(id: user.id).present?
  end
end
