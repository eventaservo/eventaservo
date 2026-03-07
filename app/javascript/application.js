// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

// jQuery — expose globally for Rails UJS and legacy plugins
import $ from 'jquery'
window.$ = window.jQuery = $

// Bootstrap 5 JS (jQuery-free, uses @popperjs/core)
import * as bootstrap from 'bootstrap'
window.bootstrap = bootstrap

// Rails UJS — handles data-method, data-confirm, remote: true
import Rails from '@rails/ujs'
Rails.start()

// ActiveStorage — direct uploads
import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()

// Disables Turbo Drive, since it's conflicting with FullCalendar.
// After solving the issue, you can remove this line.
Turbo.session.drive = false

import './src/trix'
import './controllers'
import 'trix'
import '@rails/actiontext'

// Leaflet
import L from 'leaflet'
window.L = L
import 'leaflet.markercluster'

// Chartkick
import "chartkick"
import Highcharts from "highcharts"
window.Highcharts = Highcharts

// Direct upload progress UI
import './src/direct_uploads'

