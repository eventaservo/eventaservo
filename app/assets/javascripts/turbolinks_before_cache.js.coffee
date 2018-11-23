document.addEventListener 'turbolinks:before-cache', ->
  # Summernote
  $('[data-provider="summernote"]').summernote 'destroy'

  # Select2
  if $('.select2-input').hasClass('select2-hidden-accessible')
    $('.select2-input').select2 'destroy'

  return
