require "rails_helper"

RSpec.describe ActiveSupport::TimeZone do
  describe ".cet?" do
    it "should return true for timezones that are CET" do
      expect(ActiveSupport::TimeZone["Europe/Paris"].cet?).to be true
    end

    it "should return false for timezones that are not CET" do
      expect(ActiveSupport::TimeZone["America/New_York"].cet?).to be false
    end
  end
end
