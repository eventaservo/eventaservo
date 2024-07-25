require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_date" do
    it "should default format date to long" do
      date = Date.new(1978, 7, 17)
      expect(format_date(date)).to eq("lundo, 17 julio 1978")
    end
  end

  describe "#color_event" do
    it "should return gray for past events" do
      expect(color_event(build_stubbed(:event, :past))).to eq("gray")
    end

    it "should return green for future events" do
      expect(color_event(build_stubbed(:event, :future))).to eq("green")
    end
  end

  describe "#markdown" do
    it "should return html" do
      expect(markdown("**PROVO**")).to eq("<p><strong>PROVO</strong></p>\n")
    end
  end

  describe "#page_title" do
    it "should return page title html" do
      expect(page_title("Titolo", "sub-titolo")).to eq('<h2 class="text-center">Titolo<small> sub-titolo</small></h2>')
    end
  end

  describe "#flash_class" do
    it "should return class color 'primary' for :notice" do
      expect(flash_class(:notice)).to eq("alert-primary")
    end

    it "should return class color 'success' for :success" do
      expect(flash_class(:success)).to eq("alert-success")
    end

    it "should return class color 'danger' for :error" do
      expect(flash_class(:error)).to eq("alert-danger")
    end

    it "should return class color 'warning' for :alert" do
      expect(flash_class(:alert)).to eq("alert-warning")
    end

    it "should return class color 'info' for :alia" do
      expect(flash_class(:alia)).to eq("alert-info")
    end
  end

  describe "#event_date" do
    it "should return formatted event dates" do
      event = create(:evento)
      event.update(time_zone: "Etc/UTC")

      # Samtaga evento
      event.update!(
        date_start: Time.new(2018, 7, 17, 12, 0, 0).in_time_zone(event.time_zone),
        date_end: Time.new(2018, 7, 17, 12, 0, 0).in_time_zone(event.time_zone)
      )
      expect(event_date(event)).to eq "mardo, 17 julio 2018"

      # sammonata evento
      event.update!(date_end: Time.new(2018, 7, 21, 12, 0, 0).in_time_zone(event.time_zone))
      expect(event_date(event)).to eq "17 - 21 julio 2018"

      # malsammonata evento
      event.update!(date_end: Time.new(2018, 8, 21, 12, 0, 0).in_time_zone(event.time_zone))
      expect(event_date(event)).to eq "17 julio - 21 aŭgusto 2018"

      # malsamjara evento
      event.update!(date_end: Time.new(2019, 1, 6, 12, 0, 0).in_time_zone(event.time_zone))
      expect(event_date(event)).to eq "17 julio 2018 - 6 januaro 2019"
    end
  end

  describe "#event_full_description" do
    it "should return the full address for RSS" do
      event = create(:event, :brazila)
      event.date_start = Time.zone.parse("1978-07-17 21:00:00 +03:00")
      event.date_end = event.date_start + 1.hour
      event.description = "Grava tago"
      event.city = "San-Paŭlo"
      event.save!

      expect(event_full_description(event)).to eq "lundo, 17 julio 1978 (Brazilo - San-Paŭlo)<br/>Grava tago"
    end
  end
end
