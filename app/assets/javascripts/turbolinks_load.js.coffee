$(document).on "turbolinks:load", ->
  $ ->
    $('.datepicker').datepicker dateFormat: 'dd/mm/yy'

  $ ->
    $('.datepicker').mask '00/00/0000', placeholder: "__/__/____"

  $ ->
    $('[data-toggle="tooltip"]').tooltip()

  $ ->
    $('.select2-input').select2
      theme: 'bootstrap'
    $('.js-smartPhoto').SmartPhoto()

    $('#search_form input').keyup (event)->
      if (event.which == 13)
        $(this).blur()
      else
        delay (->
          $.get $('#search_form').attr('action'), $('#search_form').serialize(), null, 'script'
        ), 500
