eventCalendar = ->
  $('#full_calendar').fullCalendar {
    events:
      url: '/events.json'
      data:
        continent: $('#full_calendar').data('continent')
        country: $('#full_calendar').data('country')
        city: $('#full_calendar').data('city')
        o: $('#full_calendar').data('o')
        s: $('#full_calendar').data('s')
        username: $('#full_calendar').data('username')
    eventColor: 'green'
    timeFormat: 'H:mm'
    plugins: [ 'list' ]
    defaultView: 'monato'
    contentHeight: 'auto'
    displayEventTime: true
    header:
      left: 'today'
      center: 'title'
      right: 'semajno,monato,listo prev,next'
    buttonText:
      today: 'hodiaŭ'
    titleFormat: 'D MMMM YYYY'
    listDayFormat: 'dddd, D MMMM YYYY'
    listDayAltFormat: false
    noEventsMessage: 'Eventoj ne okazas'
    monthNames: ['januaro', 'februaro', 'marto', 'aprilo', 'majo', 'junio', 'julio', 'aŭgusto', 'septembro', 'oktobro', 'novembro', 'decembro']
    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Ĵaŭ', 'Ven', 'Sab']
    dayNames: ['Dimanĉo', 'Lundo', 'Mardo', 'Merkredo', 'Ĵaŭdo', 'Vendredo', 'Sabato']
    views:
      today: 'hodiaŭ'
      listo:
        type: 'list'
        duration:
          days: 7
        buttonText: 'Listo'
        allDayText: 'tuttaga'
      semajno:
        buttonText: '7 tagoj'
        type: 'agenda'
        dayCount: 7
      monato:
        type: 'month'
        buttonText: 'Monato'
        eventLimit: 4
        eventLimitText: 'pli'
    eventClick: (e) ->
      if e.url
        window.open e.url, '_blank'
        return false
  }

clearCalendar = ->
  $('#full_calendar').html ''

# Rilate Turbolinks
$(document).on 'turbolinks:load', eventCalendar
$(document).on 'turbolinks:before-cache', clearCalendar
