$(function() {
  $('#copy_button').click(function() {
    $('#webcalurl').select();
    document.execCommand('copy');
    alert('Ligilo sukcese kopiita al la tondujo!');
  });

  $('.copy-to-clipboard').click(function() {
    var text = $(this).data('clipboard');
    navigator.clipboard.writeText(text);
    alert(text + ' sukcese kopiita al la tondujo!');
  });
});

