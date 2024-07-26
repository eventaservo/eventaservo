import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-problem-form"
export default class extends Controller {
  connect() {
    $('#reportProblemModal').on('shown.bs.modal', function () {
      if ($('#name').val() === "") {
        $('#name').focus();
      } else {
        $('#message').focus();
      }
    });
  }
}
