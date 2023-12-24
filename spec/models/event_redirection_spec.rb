require "rails_helper"

RSpec.describe EventRedirection, type: :model do
  describe "Validations" do
    it "factory should be valid" do
      expect(build_stubbed(:event_redirection)).to be_valid
    end

    it { should validate_presence_of(:old_short_url) }
    it { should validate_presence_of(:new_short_url) }
  end
end
