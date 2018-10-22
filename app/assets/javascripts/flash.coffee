$(document).on "turbolinks:load", ->
  # Dismiss Flash after 7 seconds
  delay (->
    $('#flash').fadeOut
      duration: 1000
  ), 5000
