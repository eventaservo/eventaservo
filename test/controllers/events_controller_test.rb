# frozen_string_literal: true

require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @brazila_evento = events(:brazilo)
  end

  test 'devas listigi la validajn kontinentajn eventojn' do
    valid_continents = %w[
      /Afriko /afriko /Ameriko /ameriko /Azio /azio /Euxropo /euxropo /E%C5%ADropo /e%C5%ADropo
      /Oceanio /oceanio /Reta /reta
    ]

    valid_continents.each do |continent|
      get continent
      assert_response :success
    end
  end

  test 'devas montri la ĉefpaĝon se la kontinento ne ekzistas' do
    get '/NevalidaKontinento'
    assert_redirected_to root_path
    assert_equal 'Ne estas eventoj en tiu kontinento', flash[:notice]
  end

  test 'devas montri urban paĝon se urbo nomo validas'do
    get '/ameriko/brazilo'
    assert_response :success

    get '/E%C5%ADropo/%C4%88e%C4%A5io'
    assert_response :success

    get '/euxropo/cxehxio'
    assert_response :success
  end

  test 'direktas la uzanton al ĉefapaĝo se uzantnomo ne ekzistas' do
    get '/uzanto/ne_valida_uzantnomo'
    assert_redirected_to root_path
    assert_equal 'Uzantnomo ne ekzistas', flash[:error]
  end

  # setup do
  #   @event = events(:one)
  # end
  #
  # test "should get index" do
  #   get events_url
  #   assert_response :success
  # end
  #
  # test "should get new" do
  #   get new_event_url
  #   assert_response :success
  # end
  #
  # test "should create event" do
  #   assert_difference('Event.count') do
  #     post events_url, params: { event: { date_end: @event.date_end, date_start: @event.date_start, description: @event.description, title: @event.title, user_id: @event.user_id } }
  #   end
  #
  #   assert_redirected_to event_url(Event.last)
  # end
  #
  # test "should show event" do
  #   get event_url(@event)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_event_url(@event)
  #   assert_response :success
  # end
  #
  # test "should update event" do
  #   patch event_url(@event), params: { event: { date_end: @event.date_end, date_start: @event.date_start, description: @event.description, title: @event.title, user_id: @event.user_id } }
  #   assert_redirected_to event_url(@event)
  # end

  # test "should destroy event" do
  #   assert_difference('Event.count', -1) do
  #     delete event_url(@event)
  #   end
  #
  #   assert_redirected_to events_url
  # end
end
