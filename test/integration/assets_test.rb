# frozen_string_literal: true

require "test_helper"

# Integration tests for application assets.
# Guards against ECMAScript syntax and RegExp features incompatible with
# older mobile and desktop browsers (such as Firefox < 78 / Firefox Mobile 68).
#
# Sentry EVENTA-SERVO-1DJ: Firefox < 78 does not support Unicode property escapes
# (\p{...}), parsing \p inside /.../u as an invalid identity escape and throwing:
# "SyntaxError: invalid identity escape in regular expression".
class AssetsTest < ActionDispatch::IntegrationTest
  test "application.js bundle does not contain unicode property escapes" do
    bundle_path = Rails.root.join("app/assets/builds/application.js")
    assert File.exist?(bundle_path), "Expected #{bundle_path} to exist"

    content = File.read(bundle_path)
    assert_nil content.match(%r{\\p\{[A-Za-z_]+\}}),
      "application.js contains an unsupported Unicode property escape (EVENTA-SERVO-1DJ)"
  end
end
