# frozen_string_literal: true

require 'test_helper'

module Api
  class EventsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def setup
      @token = Rails.application.credentials.dig(:jwt, :test_user_token)
    end

    test 'Lists events' do
      FactoryBot.create(:user, id: 1)
      event = FactoryBot.create(:evento)

      get '/api/v2/eventoj', headers: { HTTP_AUTHORIZATION: @token }, params: { uuid: event.uuid }
      assert_response :success

      response = JSON.parse(@response.body)

      assert_not response.empty?
      assert response.count == 1
    end
    # test 'Lista resumo de pagamentos no ano atual' do
    #   FactoryBot.create(:hqq_pagamento, valor: 45)
    #   FactoryBot.create(:hqq_pagamento, valor: 500, quantidade: 2)

    #   ano = Date.today.year
    #   get "/api/v6/hqq/pagamentos/resumo?ano=#{ano}", headers: { HTTP_AUTHORIZATION: @token }
    #   assert_response :success

    #   resp = JSON.parse(@response.body)
    #   assert resp['resumo'].count == 4

    #   resumo = resp['resumo']

    #   assert resumo['pagamentos'].present?
    #   assert resumo['pagamentos'] == 2

    #   assert resumo['distintos'].present?
    #   assert resumo['distintos'] == 3

    #   assert resumo['novosPagadores'].present?
    #   assert resumo['novosPagadores'] == 3

    #   assert resumo['total'].present?
    #   assert resumo['total'] == 545
    # end
  end
end
