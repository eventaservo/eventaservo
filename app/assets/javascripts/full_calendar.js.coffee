eventCalendar = ->
  $('#full_calendar').fullCalendar {
    events:
      url: '/events.json'
      data:
        country: $('#full_calendar').data('country')
        city: $('#full_calendar').data('city')
        username: $('#full_calendar').data('username')
    eventColor: 'green'
    height: 'auto'
    fixedWeekCount: false
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
    eventRender: (eventObj, $el) ->
      $el.popover
        title: eventObj.title
        content: eventObj.description
        trigger: 'hover'
        placement: 'top'
        container: 'body'
  }

clearCalendar = ->
  $('#full_calendar').fullCalendar 'delete' # In case delete doesn't work.
  $('#full_calendar').html ''

# Por Turbolinks
$(document).on 'turbolinks:load', eventCalendar
$(document).on 'turbolinks:before-cache', clearCalendar
