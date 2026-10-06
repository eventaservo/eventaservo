# frozen_string_literal: true

# Rack caps the memory used by nested query/body parameters.
# Raise it to 16 MB so large forms with deeply nested attributes are parsed.
Rack::Utils.default_query_parser = Rack::QueryParser.make_default(
  Rack::Utils.param_depth_limit, bytesize_limit: 16_777_216
)
