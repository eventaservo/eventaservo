require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @event = FactoryBot.create(:event)
    @user = FactoryBot.create(:user)
  end

  context "Associations" do
    should belong_to(:user)
    should belong_to :country
    should have_many :organization_events
    should have_many :organizations
    should have_many :participants
    should have_many :participants_records
    should have_many :videoj
    should have_many :reports
    should have_rich_text :enhavo
    should have_many_attached :uploads
  end

  context "Validations" do
    should validate_presence_of(:title)
    should validate_presence_of(:description)
    should validate_presence_of(:city)
    should validate_presence_of(:date_start)
    should validate_presence_of(:date_end)
    should validate_presence_of(:code)
    should validate_length_of(:title).is_at_most(100)
    should validate_length_of(:description).is_at_most(400)
  end

  test "fina dato devas esti post komenca dato" do
    evento = build(:evento)
    evento.date_start = Time.zone.today
    evento.date_end = Time.zone.today - 1.day
    assert_not evento.save
  end

  test "forigas kaj malforigas la eventon, sed ne el la datumbazo" do
    @event.delete!
    assert_equal @event.deleted, true

    @event.undelete!
    assert_equal @event.deleted, false
  end

  test "serĉado" do
    evento = create(:evento, :brazila)
    assert Event.search("brazilo").exists?(id: evento.id)
  end

  test "retejo devas enhavi http se ankoraŭ ne havas ĝin" do
    @event.update!(site: "google.com")
    assert_equal "https://google.com", @event.site
  end

  test "ne aldonu http se retejo jam havas ĝin" do
    @event.update!(site: "https://google.com")
    assert_equal "https://google.com", @event.site
  end

  test "ne aldonu http se ne estas retejo" do
    @event.update!(site: nil)
    assert_nil @event.site

    @event.update!(site: "")
    assert_nil @event.site

    @event.update!(site: " ")
    assert_nil @event.site

    @event.update!(site: "google.com")
    assert_equal "https://google.com", @event.site
  end

  test "forigas malpermesatajn signojn el urbonomo" do
    @event.update!(city: "urbo / alia urbo")
    assert_equal "urbo  alia urbo", @event.city
  end

  test "geocoder, dum provoj, devas informi la NY adreson" do
    event = create(:evento, :usona)
    event.geocode
    event.save!
    assert_equal 40.71, event.latitude
    assert_equal(-74.00, event.longitude)
  end

  test "endas plenumi retadreson au retposhtadreson" do
    evento = build_stubbed(:evento)
    assert evento.valid?

    evento.site = nil
    evento.email = nil
    assert evento.invalid?

    evento.site = Faker::Internet.url
    assert evento.valid?

    evento.site = nil
    evento.email = Faker::Internet.email
    assert evento.valid?
  end

  test ".cet?" do
    london_event = build(:evento, time_zone: "Europe/London")
    assert_not london_event.cet?

    paris_event = build(:evento, time_zone: "Europe/Paris")
    assert paris_event.cet?
  end

  test ".komenca_dato" do
    date_start = Time.parse("2023-02-13 15:00 UTC")

    event = FactoryBot.build(:evento, date_start: date_start, date_end: date_start + 1.hour)
    assert_equal date_start.in_time_zone("UTC"), event.komenca_dato
    assert_equal date_start.in_time_zone("America/Recife"), event.komenca_dato(horzono: "America/Recife")
  end

  test ".fina_dato" do
    date_end = Time.parse("2023-02-13 16:00 UTC")

    event = FactoryBot.build(:evento, date_start: date_end - 1.hour, date_end: date_end)
    assert_equal date_end.in_time_zone("UTC"), event.fina_dato
    assert_equal date_end.in_time_zone("America/Recife"), event.fina_dato(horzono: "America/Recife")
  end

  test ".add_participant" do
    assert_difference "@event.participants.count", 1 do
      @event.add_participant(@user)
    end
  end

  test ".remove_participant" do
    @event.add_participant(@user)

    assert_difference "@event.participants.count", -1 do
      @event.remove_participant(@user)
    end
  end

  test "normalize title" do
    event1 = FactoryBot.create(:event, title: "UEA Universala Kongreso")
    assert_equal "UEA Universala Kongreso", event1.title

    event2 = FactoryBot.create(:event, title: "UEA UNIVERSALA KONGRESO  ")
    assert_equal "Uea Universala Kongreso", event2.title
  end

  test "#past?" do
    past_event = FactoryBot.build(:event, date_start: 1.day.ago, date_end: 1.day.ago)
    assert past_event.past?

    past_event.update(date_end: Time.zone.today)
    assert_not past_event.past?
  end
end
