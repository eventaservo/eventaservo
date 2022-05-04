# frozen_string_literal: true

require 'test_helper'

module Api
  class EventsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def setup
      @token = Rails.application.credentials.dig(:jwt, :test_user_token)
    end

    test 'List event by UUID' do
      event = FactoryBot.create(:evento)

      get '/api/v2/eventoj', headers: { HTTP_AUTHORIZATION: @token }, params: { uuid: event.uuid }
      assert_response :success

      response = JSON.parse(@response.body)

      assert_not response.empty?
      assert response.count == 1
      assert response.first['titolo'] == event.title
    end

    test 'Return error when listing events without required parameters' do
      get '/api/v2/eventoj', headers: { HTTP_AUTHORIZATION: @token }
      assert_response 400

      response = JSON.parse(@response.body)
      assert_not response.empty?
      assert response['eraro'].present?
    end
  end
end
