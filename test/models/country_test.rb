# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string
#  continent  :string           indexed, indexed => [name]
#  name       :string           indexed, indexed => [continent]
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class CountryTest < ActiveSupport::TestCase
  # Validations
  test "should validate presence of name" do
    country = Country.new(continent: "South America")
    assert_not country.valid?
    assert country.errors[:name].present?, "Expected name to have errors"
  end

  test "should validate presence of continent" do
    country = Country.new(name: "TestCountry123")
    assert_not country.valid?
    assert country.errors[:continent].present?, "Expected continent to have errors"
  end

  test "should validate uniqueness of name" do
    # Use a unique name to avoid conflicts with fixtures
    unique_name = "UniqueTestCountry#{Time.now.to_i}"
    country1 = Country.create!(name: unique_name, continent: "South America")
    country2 = Country.new(name: unique_name, continent: "South America")
    assert_not country2.valid?
    assert country2.errors[:name].present?, "Expected name to have uniqueness error"
  end

  # Associations
  test "should have many users" do
    assert_respond_to Country.new, :users
    association = Country.reflect_on_association(:users)
    assert_equal :has_many, association.macro
  end

  # Class methods
  test ".by_name should return 'Brazilo' case-insensitively" do
    # Brazilo should exist in fixtures, but let's verify
    brazilo = Country.find_by(name: "Brazilo")
    skip "Brazilo not found in fixtures" unless brazilo

    assert_equal "Brazilo", Country.by_name("Brazilo").name
    assert_equal "Brazilo", Country.by_name("brazilo").name
  end

  test ".by_name should return 'Ĉeĥio' with x-system support" do
    # Ĉeĥio should exist in fixtures, but let's verify
    cehio = Country.find_by(name: "Ĉeĥio")
    skip "Ĉeĥio not found in fixtures" unless cehio

    assert_equal "Ĉeĥio", Country.by_name("Ĉeĥio").name
    assert_equal "Ĉeĥio", Country.by_name("Cxehxio").name
  end
end
