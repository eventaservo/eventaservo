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
require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:continent) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { should have_many(:users) }
  end

  describe "class methods" do
    describe ".by_name" do
      it "should return 'Brazilo'" do
        expect(described_class.by_name("Brazilo").name).to eq("Brazilo")
        expect(described_class.by_name("brazilo").name).to eq("Brazilo")
      end

      it "should return 'Ĉeĥio'" do
        expect(described_class.by_name("Ĉeĥio").name).to eq("Ĉeĥio")
        expect(described_class.by_name("Cxehxio").name).to eq("Ĉeĥio")
      end
    end
  end
end
