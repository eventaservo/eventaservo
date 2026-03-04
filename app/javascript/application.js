// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

// jQuery — expose globally for Bootstrap and Rails UJS
import $ from 'jquery'
window.$ = window.jQuery = $

// Bootstrap JS (includes Popper.js for dropdowns, tooltips, etc.)
import 'bootstrap'

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
import 'leaflet'
import 'leaflet.markercluster'

// Chartkick
import "chartkick"
import Highcharts from "highcharts"
window.Highcharts = Highcharts

// Direct upload progress UI
import './src/direct_uploads'

// Fixes slim-select option selection inside Bootstrap modals
$.fn.modal.Constructor.prototype._enforceFocus = function () { }
