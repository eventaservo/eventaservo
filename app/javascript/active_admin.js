// ActiveAdmin JS bundle — replaces Sprockets-based vendor/assets/javascripts/active_admin.js
// Sets up jQuery globally for ActiveAdmin, then loads its base JS + charting libs.

import jQuery from "jquery"
window.jQuery = jQuery
window.$ = jQuery

import "jquery-ui-dist/jquery-ui"

import "./vendor/active_admin_base"

import Chartkick from "chartkick"
import Highcharts from "highcharts"
Chartkick.use(Highcharts)
window.Chartkick = Chartkick
