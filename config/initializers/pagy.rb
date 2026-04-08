# frozen_string_literal: true

# Pagy DEFAULT Variables
Pagy::DEFAULT[:items] = 15
Pagy::DEFAULT[:page_param] = :pagho

# Extras
require "pagy/extras/array"
require "pagy/extras/bootstrap"
require "pagy/extras/trim"
