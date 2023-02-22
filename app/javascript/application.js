// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'controllers'
import '@hotwired/turbo-rails'

import "trix"
import "@rails/actiontext"

// Disables Turbo Drive, since it's conflicting with Wekpacker.
// After solving the issue, you can remove this line.
Turbo.session.drive = false
