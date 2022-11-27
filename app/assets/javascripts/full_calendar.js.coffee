$ ->
  $('#full_calendar').fullCalendar {
    events:
      url: '/events.json'
      data:
        continent: $('#full_calendar').data('continent')
        country: $('#full_calendar').data('country')
        city: $('#full_calendar').data('city')
        o: $('#full_calendar').data('o')
        s: $('#full_calendar').data('s')
        t: $('#full_calendar').data('t')
        username: $('#full_calendar').data('username')
    eventColor: 'green'
    timeFormat: 'H:mm'
    plugins: [ 'list' ]
    defaultView: 'listo'
    contentHeight: 'auto'
    displayEventTime: true
    header:
      left: 'title'
      center: ''
      right: 'monato,listo prev,next'
    buttonText:
      today: 'hodiaŭ'
    titleFormat: 'D MMMM YYYY'
    listDayFormat: 'dddd, D MMMM YYYY'
    listDayAltFormat: false
    firstDay: 1
    noEventsMessage: 'Eventoj ne okazas dum ĉi tiu semajno. Elektu alian semajnon aŭ monaton.'
    monthNames: ['januaro', 'februaro', 'marto', 'aprilo', 'majo', 'junio', 'julio', 'aŭgusto', 'septembro', 'oktobro', 'novembro', 'decembro']
    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Ĵaŭ', 'Ven', 'Sab']
    dayNames: ['Dimanĉo', 'Lundo', 'Mardo', 'Merkredo', 'Ĵaŭdo', 'Vendredo', 'Sabato']
    views:
      today: 'hodiaŭ'
      listo:
        type: 'list'
        duration:
          days: 7
        buttonText: 'Semajno'
        allDayText: 'tuttaga'
      monato:
        type: 'month'
        buttonText: 'Monato'
        eventLimit: 5
        eventLimitText: ''
        dayPopoverFormat: 'dddd, D MMMM'
  }
