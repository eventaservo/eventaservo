$ ->
  $('#copy_button').click ->
    $('#webcalurl').select()
    document.execCommand('copy')
    alert 'Ligilo sukcese kopiita al la tondujo!'

  $('.copy-to-clipboard').click ->
    text = $('.copy-to-clipboard').data('clipboard')
    navigator.clipboard.writeText(text);
    alert text + ' sukcese kopiita al la tondujo!'
