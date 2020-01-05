$ ->
  $('#search_container').hide();

  $('#search_icon').click ->
    if $('#search_container').is(':hidden')
      $('#search_container').show()
      $('#search_container input').focus()
    else
      $('#search_container input').val('')
      $.get $('#search_form').attr('action'), $('#search_form').serialize(), null, 'script'
      $('#search_container').hide()
