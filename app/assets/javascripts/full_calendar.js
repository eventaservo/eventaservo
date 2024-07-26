document.addEventListener('DOMContentLoaded', function() {
  var fullCalendarElement = document.getElementById('full_calendar');

  $('#full_calendar').fullCalendar({
    events: {
      url: '/events.json',
      data: {
        continent: fullCalendarElement.dataset.continent,
        country: fullCalendarElement.dataset.country,
        city: fullCalendarElement.dataset.city,
        o: fullCalendarElement.dataset.o,
        s: fullCalendarElement.dataset.s,
        t: fullCalendarElement.dataset.t,
        username: fullCalendarElement.dataset.username
      }
    },
    eventColor: 'green',
    timeFormat: 'H:mm',
    plugins: ['list'],
    defaultView: 'listo',
    contentHeight: 'auto',
    displayEventTime: true,
    header: {
      left: 'title',
      center: '',
      right: 'monato,listo prev,next'
    },
    buttonText: {
      today: 'hodiaŭ'
    },
    titleFormat: 'D MMMM YYYY',
    listDayFormat: 'dddd, D MMMM YYYY',
    listDayAltFormat: false,
    firstDay: 1,
    noEventsMessage: 'Eventoj ne okazas dum ĉi tiu semajno. Elektu alian semajnon aŭ monaton.',
    monthNames: ['januaro', 'februaro', 'marto', 'aprilo', 'majo', 'junio', 'julio', 'aŭgusto', 'septembro', 'oktobro', 'novembro', 'decembro'],
    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Ĵaŭ', 'Ven', 'Sab'],
    dayNames: ['Dimanĉo', 'Lundo', 'Mardo', 'Merkredo', 'Ĵaŭdo', 'Vendredo', 'Sabato'],
    views: {
      today: 'hodiaŭ',
      listo: {
        type: 'list',
        duration: {
          days: 7
        },
        buttonText: 'Semajno',
        allDayText: 'tuttaga'
      },
      monato: {
        type: 'month',
        buttonText: 'Monato',
        eventLimit: 5,
        eventLimitText: '',
        dayPopoverFormat: 'dddd, D MMMM'
      }
    }
  });
});
