# frozen_string_literal: true

require 'test_helper'

class OrganizationsTest < ActiveSupport::TestCase
  test 'nova organizo devas fiaski sen nomo' do
    organizo = build(:organizo, name: nil)
    assert organizo.invalid?
  end

  test 'nova organizo devas fiaski sen mallonga nomo' do
    organizo = build(:organizo, short_name: nil)
    assert organizo.invalid?
  end

  test 'organizo kapablas havi uzantojn' do
    assert_not_nil Organization.reflect_on_association(:uzantoj)
  end

  test 'organizo kapablas havi eventojn' do
    assert_not_nil Organization.reflect_on_association(:eventoj)
  end

  test 'organiz_uzanto apartenas al organizo kaj uzanto' do
    assert_not_nil OrganizationUser.reflect_on_association(:organization)
    assert_not_nil OrganizationUser.reflect_on_association(:user)
  end

  test 'organiz_evento apartenas al organizo kaj evento' do
    assert_not_nil OrganizationEvent.reflect_on_association(:organization)
    assert_not_nil OrganizationEvent.reflect_on_association(:event)
  end

  test 'valiads na mallongan nomon' do
    organizo = build(:organizo, short_name: 'organizo kun spacoj')
    assert organizo.invalid?

    organizo = build(:organizo, short_name: 'organizo,kun.signoj*divers@aj')
    assert organizo.invalid?
  end

  test 'mallonga nomo devas esti minuskla' do
    organizo = create(:organizo, short_name: 'Kun_Grandaj_Literoj')
    assert_equal 'kun_grandaj_literoj', organizo.short_name
  end

  test 'mallong nomo devas esti unika' do
    create(:organizo, short_name: 'tejo')
    o = build(:organizo, short_name: 'tejo')
    assert o.invalid?
  end
end
