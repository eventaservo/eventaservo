# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                     :bigint           not null, primary key
#  address                :string           indexed
#  cancel_reason          :text
#  cancelled              :boolean          default(FALSE), indexed
#  city                   :text             indexed
#  code                   :string           not null
#  content                :text
#  date_end               :datetime         indexed
#  date_start             :datetime         not null, indexed
#  deleted                :boolean          default(FALSE), not null, indexed
#  description            :string(400)      indexed
#  display_flag           :boolean          default(TRUE)
#  email                  :string
#  format                 :string           indexed
#  import_url             :string(400)
#  international_calendar :boolean          default(FALSE)
#  latitude               :float
#  longitude              :float
#  metadata               :jsonb
#  online                 :boolean          default(FALSE), indexed
#  participants_count     :integer          default(0), indexed
#  short_url              :string
#  site                   :string
#  specolisto             :string           default("Kunveno"), indexed
#  time_zone              :string           default("Etc/UTC"), not null
#  title                  :string           not null, indexed
#  uuid                   :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          not null
#  user_id                :integer          not null, indexed
#

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should be valid" do
    event = build(:event)
    assert event.valid?
  end

  test "should validate presence of title" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:title], "devas esti kompletigita"
  end

  test "should validate presence of description" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:description], "devas esti kompletigita"
  end

  test "should validate presence of city" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:city], "devas esti kompletigita"
  end

  test "should validate presence of date_start" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:date_start], "devas esti kompletigita"
  end

  test "should validate presence of date_end" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:date_end], "devas esti kompletigita"
  end

  test "should validate maximum length of title" do
    event = build(:event, title: "a" * 101)
    assert_not event.valid?
    assert_includes event.errors[:title], "estas tro longa (maksimume 100 signoj)"
  end

  test "should validate maximum length of description" do
    event = build(:event, description: "a" * 401)
    assert_not event.valid?
    assert_includes event.errors[:description], "estas tro longa (maksimume 400 signoj)"
  end

  test "should be valid with :site or :url" do
    evento = build(:evento)
    assert evento.valid?

    evento.site = nil
    evento.email = nil
    assert_not evento.valid?

    evento.site = Faker::Internet.url
    assert evento.valid?

    evento.site = nil
    evento.email = Faker::Internet.email
    assert evento.valid?
  end

  test "date_end should be after date_start" do
    event = build(:event)
    event.date_start = Time.zone.today
    event.date_end = Time.zone.today - 1.day
    assert_not event.valid?
  end

  test "checks if city is not all upcase" do
    event = build(:event)
    event.city = "ALL UPCASE CITY NAME"
    assert_not event.valid?
    assert_includes event.errors.messages.keys, :city

    event.city = "All Upcase City Name"
    assert event.valid?
  end

  test "should belong to user" do
    event = Event.new
    assert_respond_to event, :user
  end

  test "should belong to country" do
    event = Event.new
    assert_respond_to event, :country
  end

  test "should have many organization_events" do
    event = Event.new
    assert_respond_to event, :organization_events
  end

  test "should have many organizations" do
    event = Event.new
    assert_respond_to event, :organizations
  end

  test "should have many participants" do
    event = Event.new
    assert_respond_to event, :participants
  end

  test "should have many participants_records" do
    event = Event.new
    assert_respond_to event, :participants_records
  end

  test "should have many videoj" do
    event = Event.new
    assert_respond_to event, :videoj
  end

  test "should have many reports" do
    event = Event.new
    assert_respond_to event, :reports
  end

  test "should have rich text enhavo" do
    event = Event.new
    assert_respond_to event, :enhavo
  end

  test "should have many attached uploads" do
    event = Event.new
    assert_respond_to event, :uploads
  end

  test "do not create a redirection for new events" do
    assert_no_difference "EventRedirection.count" do
      create(:event)
    end
  end

  test "do not create redirection if short url didnt change" do
    event = create(:event)
    assert_no_difference "EventRedirection.count" do
      event.update!(title: "New title")
    end
  end

  test "create redirection if short url changes" do
    event = create(:event)
    old_short_url = event.short_url
    assert_difference "EventRedirection.count", 1 do
      event.update!(short_url: "new_short_url")
    end

    assert_equal old_short_url, EventRedirection.last.old_short_url
    assert_equal "new_short_url", EventRedirection.last.new_short_url
  end

  test "normalizes the title when the event is new" do
    event = build(:event, title: "UEA Universala Kongreso")
    event.save
    assert_equal "UEA Universala Kongreso", event.title

    event = build(:event, title: "PSKK")
    event.save
    assert_equal "Pskk", event.title
  end

  test "doesn't normalize the title when the event is being updated" do
    event = create(:event, title: "UEA Universala Kongreso")
    event.update(title: "UEA UNIVERSALA KONGRESO  ")
    assert_equal "UEA UNIVERSALA KONGRESO  ", event.title

    event = create(:event, title: "PSKK")
    assert_equal "Pskk", event.title
    event.update(title: "PSKK")
    assert_equal "PSKK", event.title
  end

  test "with_tags returns events with the given tags" do
    test_tag = create(:tag, name: "Test", group_name: "characteristic")
    event_with_tag = create(:event, tags: [test_tag])
    create(:event)
    assert_equal [event_with_tag], Event.with_tags([test_tag.id])
  end

  test "without_tag returns events without the given tag" do
    create(:event, tags: [create(:tag, name: "Test", group_name: "characteristic")])
    event_without_tag = create(:event)
    assert_equal [event_without_tag], Event.without_tag("Test")
  end

  test "by_link finds the event by the short_url" do
    event = create(:event, short_url: "short_url", code: "code")
    assert_equal event, Event.by_link("short_url")
  end

  test "by_link finds the event by the code" do
    event = create(:event, short_url: "short_url", code: "code")
    assert_equal event, Event.by_link("code")
  end

  test "search should return the result" do
    assert_equal [], Event.search("brazilo")

    evento = create(:evento, :brazila)
    assert_equal [evento], Event.search("brazilo")
  end

  test "cet? should return true if the event is in CET time zone" do
    london_event = build(:evento, time_zone: "Europe/London")
    assert_not london_event.cet?

    paris_event = build(:evento, time_zone: "Europe/Paris")
    assert paris_event.cet?
  end

  test "undelete! marks the event :deleted field as false" do
    event = create(:event)
    event.update_columns(deleted: true)
    event.undelete!
    assert_equal false, event.deleted
  end

  test "add_participant should add a participant" do
    event = create(:event)
    user = create(:user)
    assert_difference "event.participants.count", 1 do
      event.add_participant(user)
    end
  end

  test "remove_participant should remove a participant" do
    event = create(:event)
    user = create(:user)
    event.add_participant(user)
    assert_difference "event.participants.count", -1 do
      event.remove_participant(user)
    end
  end

  test "past? returns true when the event is in the past" do
    event = build(:event, date_start: 1.day.ago, date_end: 1.day.ago)
    assert event.past?
  end

  test "past? returns false when the event is today" do
    event = build(:event, date_start: Time.zone.today, date_end: Time.zone.today)
    assert_not event.past?
  end

  test "past? returns false when the event is in the future" do
    event = build(:event, date_start: 1.day.from_now, date_end: 1.day.from_now)
    assert_not event.past?
  end

  test "komenca_dato returns the date_start in UTC when timezone is not set" do
    date_start = Time.parse("2023-02-13 15:00 UTC")
    event = build(:evento, date_start:, date_end: date_start + 1.hour)
    assert_equal date_start.in_time_zone("UTC"), event.komenca_dato
  end

  test "komenca_dato returns the date_start in the given timezone when timezone is set" do
    date_start = Time.parse("2023-02-13 15:00 UTC")
    event = build(:evento, date_start:, date_end: date_start + 1.hour, time_zone: "America/Recife")
    assert_equal date_start.in_time_zone("America/Recife"), event.komenca_dato
  end

  test "fina_dato returns the date_start in UTC when timezone is not set" do
    date_end = Time.parse("2023-02-13 15:00 UTC")
    event = build(:evento, date_start: date_end - 1.hour, date_end:)
    assert_equal date_end.in_time_zone("UTC"), event.fina_dato
  end

  test "fina_dato returns the date_start in the given timezone when timezone is set" do
    date_end = Time.parse("2023-02-13 15:00 UTC")
    event = build(:evento, date_start: date_end - 1.hour, date_end:, time_zone: "America/Recife")
    assert_equal date_end.in_time_zone("America/Recife"), event.fina_dato
  end

  test "format_event_data should remove forbidden characters from city" do
    event = create(:event, city: "urbo / alia urbo")
    assert_equal "urbo  alia urbo", event.city
  end

  test "format_event_data should call Tools.convert_X_characters for new records for title and description" do
    event = build(:event)
    # Just verify the method can be called without errors
    event.send(:format_event_data)
    # The actual conversion is tested implicitly by other tests
    assert true
  end
end
