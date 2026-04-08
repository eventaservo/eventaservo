# frozen_string_literal: true

# Pagy OPTIONS (replaces Pagy::DEFAULT since pagy 43)
Pagy::OPTIONS[:limit] = 15
Pagy::OPTIONS[:page_key] = "pagho"

# When you are done setting your own options freeze it, so it will not get changed accidentally
Pagy::OPTIONS.freeze
