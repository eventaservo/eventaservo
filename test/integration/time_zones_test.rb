# frozen_string_literal: true

require 'test_helper'

class PostEventTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'kontrolas ĝustan eventan horzonon' do
    sign_in create(:uzanto)
    brazilo = create(:lando, :brazilo)

    get '/eventoj/new'
    assert_difference('Event.count', 1) do
      post '/eventoj',
           params: {
             event: {
               title: Faker::Book.title, description: Faker::Lorem.sentence(3), content: Faker::Lorem.paragraph(3),
               city: 'Sao Paŭlo', country_id: brazilo.id, site: Faker::Internet.url,
               date_start: Time.zone.today.strftime('%d/%m/%Y'),
               date_end: Time.zone.today.strftime('%d/%m/%Y')
             },
             time_start: '14:00', time_end: '16:00'
           }
    end
    assert_equal 'America/Sao_Paulo', Event.first.time_zone
  end
end
