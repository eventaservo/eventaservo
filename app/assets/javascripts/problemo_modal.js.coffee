$ ->
  $('#problemoModal').on 'shown.bs.modal', ->
    if $('#name').val() == ""
      $('#name').focus()
    else
      $('#message').focus()
