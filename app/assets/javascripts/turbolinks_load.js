$(function () {
  $('.datepicker').datepicker({
    dateFormat: 'dd/mm/yy',
    firstDay: 1

  });

  $('[data-toggle="tooltip"]').tooltip();

  $('.js-smartPhoto').SmartPhoto();

  $('#search_form input').keyup(function (event) {
    if (event.which === 13) {
      $(this).blur();
    } else {
      delay(function () {
        $.get($('#search_form').attr('action'), $('#search_form').serialize(), null, 'script');
      }, 500);
    }
  });

  // Organiza serĉilo
  $('#o_search_form input').keyup(function (event) {
    delay(function () {
      $.get($('#o_search_form').attr('action'), $('#o_search_form').serialize(), null, 'script');
    }, 500);
  });
});

