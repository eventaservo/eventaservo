# # frozen_string_literal: true
#
# require 'application_system_test_case'
#
# class HomeTest < ApplicationSystemTestCase
#   def setup
#     create(:evento, :brazila)
#     Event.first.update(date_start: Date.today + 1.week, date_end: Date.today + 2.weeks)
#     create(:evento, :japana)
#   end
#
#   test 'vizitas la ĉefpaĝon' do
#     visit root_url
#     assert_selector 'div', text: '1 okazas hodiaŭ'
#   end
#
#   test 'vizitas la japanan kontinentan paĝon' do
#     visit '/Azio'
#     assert_selector 'a.button-event-count', text: 'Japanio'
#   end
# end
