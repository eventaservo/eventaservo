$(document).on "turbolinks:load", ->
  # Malaperigu Flash post 5 sekundoj
  delay (->
    $('#flash').fadeOut
      duration: 1000
  ), 5000
