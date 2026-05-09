## 2026-05-02 - [High] Cross-Site Scripting (XSS) in Video Controller
**Vulnerability:** The `VideoController#create` method incorrectly called `.html_safe` on user-supplied parameters (`params[:title]` and `params[:description]`) before saving them to the database.
**Learning:** This bypasses Rails' default automatic HTML escaping mechanisms. When these attributes were later rendered in the views (e.g. `_video.html.erb`), any malicious HTML or JavaScript strings input by a user would be executed within the browser of any user viewing the page. Calling `.html_safe` should never be used on un-trusted user input directly.
**Prevention:** Avoid calling `.html_safe` on parameters. Rely on Rails' default escaping in views, or use the `sanitize` helper in views if specific HTML tags are explicitly intended to be allowed.

## 2024-05-09 - [High] CSRF Vulnerability on Video Deletion Endpoint
**Vulnerability:** The destructive action to delete a video (`/video/:id/forigi`) was mapped to a `GET` request in `config/routes/videos.rb`.
**Learning:** Mapping a destructive or state-changing action to a `GET` request bypasses Rails' built-in Cross-Site Request Forgery (CSRF) protection. It allows attackers to forge requests (e.g., via embedded image tags like `<img src="https://example.com/video/1/forigi">`) to delete resources if an authenticated user visits the attacker's site or views an email containing the payload. `GET` requests are meant to be safe and idempotent.
**Prevention:** Destructive actions MUST be mapped to appropriate HTTP verbs (`DELETE`, `POST`, `PUT`, `PATCH`) in routes. Corresponding links in views should use `method: :delete` or button_to to ensure the requests are submitted as forms containing the CSRF token.
