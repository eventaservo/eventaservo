/* global $ */

$(document).ready(function () {
  if ($(".events.new").length > 0 || $(".events.edit").length > 0) {
    $("#event_date_start").change(function () {
      $("#event_date_end").val($("#event_date_start").val())
      $("#time_start").focus()
    })

    $("#event_date_end").change(function () {
      $("#time_end").focus()
    })

    if ($("#event_online").is(":checked") === true) {
      $("#malretaj_informoj").hide()
      $("#retaj_informoj").show()
    } else {
      $("#retaj_informoj").hide()
    }

    $("#event_online").change(function () {
      if (this.checked) {
        $("#malretaj_informoj").hide()
        return $("#retaj_informoj").show()
      } else {
        $("#malretaj_informoj").show()
        return $("#retaj_informoj").hide()
      }
    })

    $("#event_country_id").on("select2:close", function () {
      return $(".button-submit").focus()
    })

    const $inputs = $("#event_site, #event_email")
    $inputs.on("input", function () {
      return $inputs.not(this).prop("required", !$(this).val().length)
    })

    $("form").on("submit", function () {
      if ($("#event_tags").find(".active").length === 0) {
        alert("Vi devas elekti almenaŭ unu specon")
        return false
      }
    })
  }
})
