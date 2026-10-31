# frozen_string_literal: true

require "test_helper"

class OrganizationsController::ShowTest < ActionDispatch::IntegrationTest
  test "should get show" do
    organization = create(:organization)
    get organization_url(organization.short_name)
    assert_response :success
  end

  test "should render phone link when organization has phone" do
    organization = create(:organization, phone: "+55 11 99999-9999")
    get organization_url(organization.short_name)
    assert_response :success
    assert_select "a[href='tel:+55 11 99999-9999']", text: "+55 11 99999-9999"
  end

  test "should render event tabs with future events, past events, and reports" do
    organization = create(:organization)
    future_event = create(:event, date_start: 5.days.from_now, date_end: 6.days.from_now, title: "Future Event Title")
    past_event = create(:event, date_start: 5.days.ago, date_end: 4.days.ago, title: "Past Event With Report")
    past_event_no_report = create(:event, date_start: 7.days.ago, date_end: 6.days.ago, title: "Past Event Without Report")
    report = create(:event_report, event: past_event, title: "Kongresa Raporto")

    organization.events << [future_event, past_event, past_event_no_report]

    get organization_url(organization.short_name)
    assert_response :success

    assert_select "#orgTabs" do
      assert_select "#future-tab", text: /Venontaj/
      assert_select "#past-tab", text: /Pasintaj/
      assert_select "#reports-tab", text: /Raportoj/
    end

    assert_select "turbo-frame#future_events_tab"
    assert_select "a[href=?]", root_url(o: organization.short_name), count: 0
    assert_select "turbo-frame#past_events_tab"
    assert_select "turbo-frame#reports_tab"

    assert_select "#past-tab-pane" do
      assert_select ".item-row", text: /Past Event With Report/ do
        assert_select "i.fa-camera"
      end
    end

    assert_select "#reports-tab-pane" do
      assert_select "a[href='#{report.url}']", text: /Kongresa Raporto/
    end
  end

  test "should fallback to default tab when unknown tab parameter is present" do
    organization = create(:organization)
    future_event = create(:event, date_start: 5.days.from_now, date_end: 6.days.from_now, title: "Future Event")
    organization.events << future_event

    get organization_url(organization.short_name, tab: :invalid_tab)
    assert_response :success

    assert_select "#future-tab.active"
    assert_select "#future-tab-pane.show.active"
    assert_select ".item-row", text: /Future Event/
  end

  test "should activate future tab and paginate future events with venontaj_pagho parameter" do
    organization = create(:organization)
    22.times do |i|
      organization.events << create(:event, date_start: (i + 1).days.from_now, date_end: (i + 1).days.from_now + 1.day, title: "Future Event #{i + 1}")
    end

    get organization_url(organization.short_name, venontaj_pagho: 2)
    assert_response :success
    assert_select "#future-tab.active"
    assert_select "#future-tab-pane" do
      assert_select ".item-row", count: 2
      assert_select "nav.pagy-bootstrap"
    end
  end

  test "should activate past tab and paginate past events with pagho parameter" do
    organization = create(:organization)
    22.times do |i|
      organization.events << create(:event, date_start: (i + 1).weeks.ago, date_end: (i + 1).weeks.ago + 1.day, title: "Past Event #{i + 1}")
    end

    get organization_url(organization.short_name, pagho: 2)
    assert_response :success
    assert_select "#past-tab.active"
    assert_select "#past-tab-pane" do
      assert_select ".item-row", count: 2
      assert_select "nav.pagy-bootstrap"
    end
  end

  test "should activate reports tab and paginate reports with raportoj_pagho parameter" do
    organization = create(:organization)
    user = create(:user)

    22.times do |i|
      event = create(:event, date_start: (i + 1).weeks.ago, date_end: (i + 1).weeks.ago + 1.day, title: "Event #{i + 1}")
      create(:event_report, event: event, user: user, title: "Report #{i + 1}")
      organization.events << event
    end

    get organization_url(organization.short_name, raportoj_pagho: 2)
    assert_response :success

    assert_select "#reports-tab.active"
    assert_select "#reports-tab-pane" do
      assert_select ".row.small", count: 2
      assert_select "nav.pagy-bootstrap"
    end
  end

  test "should paginate reports tab to 20 records per page" do
    organization = create(:organization)
    user = create(:user)

    22.times do |i|
      event = create(:event, date_start: (i + 1).weeks.ago, date_end: (i + 1).weeks.ago + 1.day, title: "Event #{i + 1}")
      create(:event_report, event: event, user: user, title: "Report #{i + 1}")
      organization.events << event
    end

    get organization_url(organization.short_name, tab: :reports)
    assert_response :success

    assert_select "#reports-tab.active"
    assert_select "#reports-tab-pane" do
      assert_select ".row.small", count: 20
      assert_select "nav.pagy-bootstrap"
    end
  end
end
