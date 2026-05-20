# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.script_src :self, "https://browser.sentry-cdn.com"
    # style_src includes :unsafe_inline because the application currently has 100+ inline style attributes
    # and to maintain compatibility with Turbo's progress bar (hotwired/turbo-rails#729).
    policy.style_src :self, :unsafe_inline
    policy.connect_src :self, "https://*.sentry.io", "https://*.mapbox.com", "https://*.openstreetmap.org", "https://www.googleapis.com"
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # We use SecureRandom.base64(16) to ensure a cryptographically secure, per-response nonce.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

  # We only apply nonces to script-src. Adding it to style-src would require nonces on all
  # inline styles, which would block the Turbo progress bar and many other legacy inline styles.
  config.content_security_policy_nonce_directives = %w[script-src]

  # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  config.content_security_policy_nonce_auto = true

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
