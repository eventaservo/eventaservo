require "rails_helper"

RSpec.describe "Privacy" do
  it "Viewing the privacy policy" do
    visit "/privateco"
    expect(page).to have_content("Privateca politiko")

    visit "/license.txt"
    expect(page).to have_content("Privateca politiko")
  end
end
