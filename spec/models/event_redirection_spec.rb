# == Schema Information
#
# Table name: event_redirections
#
#  id            :bigint           not null, primary key
#  hits          :integer          default(0), not null
#  new_short_url :string           not null
#  old_short_url :string           not null, uniquely indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
