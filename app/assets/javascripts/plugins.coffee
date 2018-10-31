$(document).on "turbolinks:load", ->
  $ ->
    $('.datepicker').datepicker dateFormat: 'dd/mm/yy'

  $ ->
    $('.datepicker').mask '00/00/0000', placeholder: "__/__/____"

  $ ->
    $('[data-toggle="tooltip"]').tooltip()
