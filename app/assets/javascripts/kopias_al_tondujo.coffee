$ ->
  $('#copy_button').click ->
    $('#webcalurl').select()
    document.execCommand('copy')
    alert 'Ligilo sukcese kopiita al la tondujo!'
