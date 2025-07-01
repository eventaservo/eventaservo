require "rails_helper"

RSpec.describe Event, type: :model do
  let(:event) { create(:event) }
  let(:user) { create(:user) }

  describe "validations" do
    it "should be valid" do
      event = build(:event)
      expect(event).to be_valid
    end

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:date_start) }
    it { should validate_presence_of(:date_end) }
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(400) }

    it "should be valid with :site or :url" do
      evento = build_stubbed(:evento)
      expect(evento).to be_valid

      evento.site = nil
      evento.email = nil
      expect(evento).to be_invalid

      evento.site = Faker::Internet.url
      expect(evento).to be_valid

      evento.site = nil
      evento.email = Faker::Internet.email
      expect(evento).to be_valid
    end

    it "date_end should be after date_start" do
      event = build(:event)
      event.date_start = Time.zone.today
      event.date_end = Time.zone.today - 1.day
      expect(event).to_not be_valid
    end

    it "checks if city is not all upcase" do
      event = build(:event)
      event.city = "ALL UPCASE CITY NAME"
      expect(event.valid?).to be_falsey
      expect(event.errors.messages).to include(:city)

      event.city = "All Upcase City Name"
      expect(event.valid?).to be_truthy
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to :country }
    it { should have_many :organization_events }
    it { should have_many :organizations }
    it { should have_many :participants }
    it { should have_many :participants_records }
    it { should have_many :videoj }
    it { should have_many :reports }
    it { should have_rich_text :enhavo }
    it { should have_many_attached :uploads }
  end

  describe "callbacks" do
    context "after_update" do
      it "do not create a redirection for new events" do
        expect { create(:event) }.to_not change { EventRedirection.count }
      end

      it "do not create redirection if short url didnt change" do
        event = create(:event)
        expect { event.update!(title: "New title") }.to_not change { EventRedirection.count }
      end

      it "create redirection if short url changes" do
        event = create(:event)
        old_short_url = event.short_url
        expect { event.update!(short_url: "new_short_url") }.to change { EventRedirection.count }.by(1)

        expect(EventRedirection.last.old_short_url).to eq(old_short_url)
        expect(EventRedirection.last.new_short_url).to eq("new_short_url")
      end
    end

    context "before_save" do
      context "when the event is new" do
        it "normalizes the title" do # rubocop:disable RSpec/ExampleLength
          event = build(:event, title: "UEA Universala Kongreso")
          event.save
          expect(event.title).to eq("UEA Universala Kongreso")

          event = build(:event, title: "PSKK")
          event.save
          expect(event.title).to eq("Pskk")
        end
      end

      context "when the event is being updated" do
        it "doesn't normalize the title" do
          event = create(:event, title: "UEA Universala Kongreso")
          event.update(title: "UEA UNIVERSALA KONGRESO  ")
          expect(event.title).to eq("UEA UNIVERSALA KONGRESO  ")

          event = create(:event, title: "PSKK")
          expect(event.title).to eq("Pskk")
          event.update(title: "PSKK")
          expect(event.title).to eq("PSKK")
        end
      end
    end
  end

  describe "scopes" do
    describe ".without_tag" do
      it "returns events without the given tag" do
        _event_with_tag = create(:event, tags: [create(:tag, name: "Test", group_name: "characteristic")])
        event_without_tag = create(:event)
        expect(Event.without_tag("Test")).to eq([event_without_tag])
      end
    end
  end

  describe "class methods" do
    describe ".by_link" do
      let!(:event) { create(:event, short_url: "short_url", code: "code") }

      it "finds the event by the short_url" do
        expect(Event.by_link("short_url")).to eq(event)
      end

      it "finds the event by the code" do
        expect(Event.by_link("code")).to eq(event)
      end
    end
  end

  describe "instance methods" do
    describe "#search" do
      it "should return the result" do
        expect(Event.search("brazilo")).to eq([])

        evento = create(:evento, :brazila)
        expect(Event.search("brazilo")).to eq([evento])
      end
    end

    describe "#cet?" do
      it "should return true if the event is in CET time zone" do
        london_event = build(:evento, time_zone: "Europe/London")
        expect(london_event.cet?).to be_falsey

        paris_event = build(:evento, time_zone: "Europe/Paris")
        expect(paris_event.cet?).to be_truthy
      end
    end

    describe "#delete!" do
      it "marks the event :deleted field as true" do
        event.delete!
        expect(event.deleted).to eq(true)
      end
    end

    describe "#undelete!" do
      it "marks the event :deleted field as false" do
        event.update_columns(deleted: true)
        event.undelete!
        expect(event.deleted).to eq(false)
      end
    end

    describe "#add_participant" do
      it "should add a participant" do
        expect { event.add_participant(user) }.to change { event.participants.count }.by(1)
      end
    end

    describe "#remove_participant" do
      it "should remove a participant" do
        event.add_participant(user)
        expect { event.remove_participant(user) }.to change { event.participants.count }.by(-1)
      end
    end

    describe "#past?" do
      subject { event.past? }

      context "when the event is in the past" do
        let(:event) { build(:event, date_start: 1.day.ago, date_end: 1.day.ago) }
        it { is_expected.to be_truthy }
      end

      context "when the event is today" do
        let(:event) { build(:event, date_start: Time.zone.today, date_end: Time.zone.today) }
        it { is_expected.to be_falsey }
      end

      context "when the event is in the future" do
        let(:event) { build(:event, date_start: 1.day.from_now, date_end: 1.day.from_now) }
        it { is_expected.to be_falsey }
      end
    end

    describe "#komenca_dato" do
      context "when the timezone is not set" do
        it "returns the date_start in UTC" do
          date_start = Time.parse("2023-02-13 15:00 UTC")
          event = build(:evento, date_start: date_start, date_end: date_start + 1.hour)
          expect(event.komenca_dato).to eq(date_start.in_time_zone("UTC"))
        end
      end

      context "when the timezone is set" do
        it "returns the date_start in the given timezone" do
          date_start = Time.parse("2023-02-13 15:00 UTC")
          event = build(:evento, date_start: date_start, date_end: date_start + 1.hour, time_zone: "America/Recife")
          expect(event.komenca_dato).to eq(date_start.in_time_zone("America/Recife"))
        end
      end
    end

    describe "#fina_dato" do
      context "when the timezone is not set" do
        it "returns the date_start in UTC" do
          date_end = Time.parse("2023-02-13 15:00 UTC")
          event = build(:evento, date_start: date_end - 1.hour, date_end: date_end)
          expect(event.fina_dato).to eq(date_end.in_time_zone("UTC"))
        end
      end

      context "when the timezone is set" do
        it "returns the date_start in the given timezone" do
          date_end = Time.parse("2023-02-13 15:00 UTC")
          event = build(:evento, date_start: date_end - 1.hour, date_end: date_end, time_zone: "America/Recife")
          expect(event.fina_dato).to eq(date_end.in_time_zone("America/Recife"))
        end
      end
    end
  end

  # date_start = Time.parse("2023-02-13 15:00 UTC")

  # event = FactoryBot.build(:evento, date_start: date_start, date_end: date_start + 1.hour)
  # assert_equal date_start.in_time_zone("UTC"), event.komenca_dato
  # assert_equal date_start.in_time_zone("America/Recife"), event.komenca_dato(horzono: "America/Recife")

  describe "private methods" do
    describe "#format_event_data" do
      it "should remove forbidden characters from city" do
        event.update(city: "urbo / alia urbo")
        expect(event.city).to eq("urbo  alia urbo")
      end

      it "should call Tools.convert_X_characters for new records for title and description" do
        event = build(:event)
        expect(Tools).to receive(:convert_X_characters).with(event.title)
        expect(Tools).to receive(:convert_X_characters).with(event.description)
        event.send(:format_event_data)
      end
    end
  end
end
