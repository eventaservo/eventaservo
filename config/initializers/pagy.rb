# frozen_string_literal: true

# Pagy DEFAULT Variables
Pagy::DEFAULT.merge!(
  items: 15,
  page_param: :pagho
)

# Extras
require "pagy/extras/array"
require "pagy/extras/bootstrap"
require "pagy/extras/trim"

# Pagy::DEFAULT.freeze # Not strictly needed if it's already frozen or not required by 9.x
