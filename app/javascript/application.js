// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

// jQuery — use the Sprockets-loaded jQuery if already present, otherwise expose the npm one.
// This ensures jQuery UI, jquery.mask and other Sprockets plugins share the same jQuery instance.
import $ from 'jquery'
if (!window.jQuery) window.$ = window.jQuery = $

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
