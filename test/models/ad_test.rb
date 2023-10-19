require "test_helper"

class AdTest < ActiveSupport::TestCase
  test "should fail if no url" do
    ad = FactoryBot.build(:ad)

    assert ad.valid?

    ad.url = nil
    assert_not ad.valid?
  end
end
