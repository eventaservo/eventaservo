# frozen_string_literal: true

require "test_helper"

class Users::TeachersAndSpeakersQueryTest < ActiveSupport::TestCase
  setup do
    @teacher = users(:teacher)
    @speaker = users(:speaker)
    @teacher_and_speaker = users(:teacher_and_speaker)
  end

  # -- Without filters --

  test "without filters returns random results with filtering? false" do
    result = Users::TeachersAndSpeakersQuery.new.call

    assert_not result.filtering?
    assert_operator result.instruistoj.size, :<=, 1
    assert_operator result.prelegantoj.size, :<=, 1
  end

  # -- Filter by name --

  test "filter by name returns matching teachers and speakers" do
    result = Users::TeachersAndSpeakersQuery.new(name: "Ana").call

    assert result.filtering?
    assert_includes result.instruistoj, @teacher
    assert_empty result.prelegantoj
  end

  test "filter by name is case-insensitive" do
    result = Users::TeachersAndSpeakersQuery.new(name: "ana").call

    assert_includes result.instruistoj, @teacher
  end

  # -- Filter by country_id --

  test "filter by country_id returns users from that country" do
    result = Users::TeachersAndSpeakersQuery.new(country_id: @teacher.country_id.to_s).call

    assert result.filtering?
    assert_includes result.instruistoj, @teacher
    assert_includes result.prelegantoj, @speaker
    assert_not_includes result.instruistoj, @teacher_and_speaker
    assert_not_includes result.prelegantoj, @teacher_and_speaker
  end

  # -- Filter by level --

  test "filter by level only affects instruistoj" do
    result = Users::TeachersAndSpeakersQuery.new(level: "baza").call

    assert result.filtering?
    assert_includes result.instruistoj, @teacher
    assert_not_includes result.instruistoj, @teacher_and_speaker
    # prelegantoj are not filtered by level
    assert_includes result.prelegantoj, @speaker
    assert_includes result.prelegantoj, @teacher_and_speaker
  end

  # -- Filter by keyword --

  test "filter by keyword filters instruistoj by sperto and prelegantoj by temoj" do
    result = Users::TeachersAndSpeakersQuery.new(keyword: "literaturo").call

    assert result.filtering?
    assert_includes result.instruistoj, @teacher_and_speaker
    assert_not_includes result.instruistoj, @teacher
    assert_includes result.prelegantoj, @teacher_and_speaker
    assert_not_includes result.prelegantoj, @speaker
  end

  # -- No matching results --

  test "returns empty relations when no users match" do
    result = Users::TeachersAndSpeakersQuery.new(name: "Nonexistent Person XYZ").call

    assert result.filtering?
    assert_empty result.instruistoj
    assert_empty result.prelegantoj
  end

  # -- LIKE metacharacter escaping --

  test "LIKE metacharacters in name are escaped" do
    special_user = create(:user, name: "Test%User",
      instruo: {instruisto: "true", nivelo: ["baza"], sperto: "test"},
      prelego: {preleganto: "false"})

    result = Users::TeachersAndSpeakersQuery.new(name: "t%u").call

    assert_includes result.instruistoj, special_user
  end

  test "LIKE underscore in name is escaped" do
    result = Users::TeachersAndSpeakersQuery.new(name: "A_a").call

    # Should not match "Ana" because _ is escaped (not a wildcard)
    assert_not_includes result.instruistoj, @teacher
  end
end
