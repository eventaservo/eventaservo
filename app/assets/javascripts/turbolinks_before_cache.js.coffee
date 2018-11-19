$(document).on "turbolinks:before-cache", ->
  $('.select2').select2('destroy')
