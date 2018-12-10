eventCalendar = ->
  $('#full_calendar').fullCalendar {
    events:
      url: '/events.json'
      data:
        continent: $('#full_calendar').data('continent')
        country: $('#full_calendar').data('country')
        city: $('#full_calendar').data('city')
        username: $('#full_calendar').data('username')
    eventColor: 'green'
    contentHeight: 500
    fixedWeekCount: false
    firstDay: 1
    displayEventTime: false
    header:
      left: 'today'
      center: 'title'
      right: 'prev,next'
    titleFormat: 'MMMM YYYY'
    buttonText:
      today: 'hodiaŭ'
      month: 'monato'
      week: 'semajno'
      day: 'tago'
      list: 'listo'
    monthNames: ['Januaro', 'Februaro', 'Marto', 'Aprilo', 'Majo', 'Junio', 'Julio', 'Aŭgusto', 'Septembro', 'Oktobro', 'Novembro', 'Decembro']
    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Ĵaŭ', 'Ven', 'Sab']
    dayNames: ['Dimanĉo', 'Lundo', 'Mardo', 'Merkredo', 'Ĵaŭdo', 'Vendredo', 'Sabato']
    views:
      month:
        eventLimit: 4
        eventLimitText: 'pli'
  }

clearCalendar = ->
  $('#full_calendar').html ''

# Por Turbolinks
$(document).on 'turbolinks:load', eventCalendar
$(document).on 'turbolinks:before-cache', clearCalendar
