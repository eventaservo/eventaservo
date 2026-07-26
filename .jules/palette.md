## 2024-06-07 - Add missing aria-labels to search form inputs
**Learning:** Found an accessibility issue where search input fields were lacking context for screen readers. In one case, the main search form input lacked an `aria-label` completely. In another case, the `aria-label` used was in English ("Search") instead of matching the primary language of the application ("Serĉi" - Esperanto), leading to confusing screen reader announcements.
**Action:** Always ensure search input forms have matching semantic labels (`aria-label` or `<label>`) and properly translate any `aria-` properties to match the native UI language.

## 2024-06-08 - Replace hardcoded English aria-labels in layouts
**Learning:** Layout partials (like `_navbar.html.erb` and `_flash.html.erb`) were using hardcoded English `aria-label`s such as "Close" and "Toggle navigation". When a user is interacting with the application in Esperanto (the primary interface language), a screen reader would announce the English term, creating a disjointed experience and violating accessibility localization guidelines.
**Action:** Always verify that structural and layout elements use localized strings (`t('...')`) for `aria-label` attributes to ensure they match the active UI language.
