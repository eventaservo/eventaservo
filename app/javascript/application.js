// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

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

// Tailwind and Flowbite
import "flowbite/dist/flowbite.turbo.js";
