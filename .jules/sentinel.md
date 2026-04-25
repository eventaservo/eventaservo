## 2026-04-25 - Unauthorized Event Cancellation
**Vulnerability:** Unauthenticated users could cancel and uncancel events. The `nuligi` and `malnuligi` endpoints in `EventsController` were not protected by `authenticate_user!` or `authorize_user` filters.
**Learning:** In Rails, when adding new actions to a controller that manages a resource, always ensure that the necessary `before_action` filters for authentication and authorization are explicitly applied to the new actions.
**Prevention:** Review all controller actions to ensure they have appropriate `before_action` filters, especially for state-mutating actions (e.g., cancelling).
