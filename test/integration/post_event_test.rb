# frozen_string_literal: true

require 'test_helper'

class PostEventTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # test 'vidas as chefpaghon' do
  #   get '/'
  #   assert_select 'h2.text-center', 'Venontaj eventoj'
  # end

  test 'kreas novan eventon' do
    sign_in create(:uzanto)
    lando = create(:lando, :brazilo)

    get '/eventoj/new'
    assert_response :success

    assert_difference('Event.count', 1) do
      post '/eventoj',
           params: {
             event: {
               title: Faker::Book.title, description: Faker::Lorem.sentence(3), content: Faker::Lorem.paragraph(3),
               city: 'Joan-Pesoo', country_id: lando.id, site: Faker::Internet.url,
               date_start: '01/01/2019', date_end: '01/01/2019'
             },
             time_start: '14:00', time_end: '16:00'
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_select 'div.flash-alert-box', /Evento sukcese kreita/
    end
  end
end
