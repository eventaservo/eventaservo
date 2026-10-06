# frozen_string_literal: true

# Rack caps the memory used by nested query/body parameters (default: 64 KB).
# Raise it to 16 MB so large forms with deeply nested attributes are parsed.
Rack::Utils.key_space_limit = 16_777_216
