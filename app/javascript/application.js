// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

// jQuery — exposed globally for Sprockets-loaded scripts (form.js, etc.)
import $ from 'jquery'
window.$ = window.jQuery = $

// Bootstrap JS (includes Popper.js for dropdowns, tooltips, etc.)
import 'bootstrap'

// Disables Turbo Drive, since it's conflicting with FullCalendar.
// After solving the issue, you can remove this line.
Turbo.session.drive = false

import './src/trix'
import './controllers'
import 'trix'
import '@rails/actiontext'

// Leaflet
import 'leaflet'
import 'leaflet.markercluster'

// Chartkick
import "chartkick"
import Highcharts from "highcharts"
window.Highcharts = Highcharts
