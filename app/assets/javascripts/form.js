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

    // RETAJ EVENTOJ -->
    if ($("#event_online").is(":checked") === true) {
      $("#retaj_informoj").show();

      if ($("#universala").is(":checked") === true) {
        $("#horzono").show()
        $("#malretaj_informoj").hide()
      } else {
        $("#horzono").hide()
      }

    } else {
      $("#horzono").hide()
      $("#retaj_informoj").hide()
      $("#malretaj_informoj").show()
    }

    $("#event_online").change(function () {
      if (this.checked) {
        return $("#retaj_informoj").show()
      } else {
        $("#universala").prop("checked", false)
        $("#malretaj_informoj").show()
        document.getElementById("event_city").value = ""
        $("#horzono").hide()
        return $("#retaj_informoj").hide()
      }
    })

    $("#universala").change(function () {
      if (this.checked) {
        $("#malretaj_informoj").hide()
        document.getElementById("event_city").value = "Reta"
        return $("#horzono").show()
      } else {
        $("#malretaj_informoj").show()
        document.getElementById("event_city").value = ""
        return $("#horzono").hide()
      }
    })
    // <-- RETAJ EVENTOJ

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
