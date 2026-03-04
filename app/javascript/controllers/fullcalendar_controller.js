import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "fullcalendar"

// Initializes FullCalendar v3 on the connected element.
//
// Reads filter parameters (continent, country, city, etc.) from
// data-calendar-*-value attributes and passes them as query params
// to the /events.json endpoint.
//
// Usage:
//   <div data-controller="calendar"
//        data-calendar-continent-value="europo"
//        data-calendar-country-value="Francio">
//   </div>
export default class extends Controller {
  static values = {
    continent: String,
    country: String,
    city: String,
    o: String,
    s: String,
    t: String,
    username: String
  }

  // Initializes the FullCalendar jQuery plugin with Esperanto locale,
  // event source, and custom views (week list + month).
  connect() {
    $(this.element).fullCalendar({
      events: {
        url: "/events.json",
        data: {
          continent: this.continentValue,
          country: this.countryValue,
          city: this.cityValue,
          o: this.oValue,
          s: this.sValue,
          t: this.tValue,
          username: this.usernameValue
        }
      },
      eventColor: "green",
      timeFormat: "H:mm",
      plugins: ["list"],
      defaultView: "listo",
      contentHeight: "auto",
      displayEventTime: true,
      header: {
        left: "title",
        center: "",
        right: "monato,listo prev,next"
      },
      buttonText: {
        today: "hodiaŭ"
      },
      titleFormat: "D MMMM YYYY",
      listDayFormat: "dddd, D MMMM YYYY",
      listDayAltFormat: false,
      firstDay: 1,
      noEventsMessage: "Eventoj ne okazas dum ĉi tiu semajno. Elektu alian semajnon aŭ monaton.",
      monthNames: ["januaro", "februaro", "marto", "aprilo", "majo", "junio", "julio", "aŭgusto", "septembro", "oktobro", "novembro", "decembro"],
      dayNamesShort: ["Dim", "Lun", "Mar", "Mer", "Ĵaŭ", "Ven", "Sab"],
      dayNames: ["Dimanĉo", "Lundo", "Mardo", "Merkredo", "Ĵaŭdo", "Vendredo", "Sabato"],
      views: {
        today: "hodiaŭ",
        listo: {
          type: "list",
          duration: { days: 7 },
          buttonText: "Semajno",
          allDayText: "tuttaga"
        },
        monato: {
          type: "month",
          buttonText: "Monato",
          eventLimit: 5,
          eventLimitText: "",
          dayPopoverFormat: "dddd, D MMMM"
        }
      }
    })
  }

  // Destroys the FullCalendar instance to prevent memory leaks on
  // page navigation.
  disconnect() {
    $(this.element).fullCalendar("destroy")
  }
}
