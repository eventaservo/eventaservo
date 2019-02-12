# frozen_string_literal: true

require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  test 'devas fiaski se havas nek land-nomon nek kontinenton' do
    country = Country.new
    assert_not country.valid?
  end

  test 'devas sukcesi se havas nomon kaj kontinento' do
    country = Country.new(name: 'Prov-lando', continent: 'Ameriko')
    assert country.valid?
  end

  test 'fiaskas se lando jam ekzistas' do
    landnomo = 'Prov-lando'
    Country.create!(name: landnomo, continent: 'Afriko')
    new_country = Country.new(name: landnomo, continent: 'Afriko')
    assert_not new_country.valid?
  end

  test 'lando havas recipients' do
    assert_not_nil Country.reflect_on_association(:recipients)

    recipient = notification_list(:one)
    country = countries(:one)
    recipient.update!(country_id: country.id)

    assert country.recipients.find_by(id: recipient.id).present?
  end

  test 'lando havas uzantoj' do
    assert_not_nil Country.reflect_on_association(:users)

    user    = users(:one)
    country = countries(:one)
    user.update!(country_id: country.id)

    assert country.users.find_by(id: user.id).present?
  end

  test 'serĉas la landon, ne gravas la ortografio' do
    assert_equal 'Brazilo', Country.by_name('brazilo').name
    assert_equal 'Ĉeĥio', Country.by_name('cxehxio').name
  end
end
