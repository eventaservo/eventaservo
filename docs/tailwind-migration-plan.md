# Tailwind CSS migration plan

- **Status**: Phase 0 spike complete (2026-11-05); Phase 1 pending
- **Date**: 2026-11-05
- **Tracking issue**: [#1514](https://github.com/eventaservo/eventaservo/issues/1514)
- **Related**: [ADR-0003](adr/0003-bootstrap-tailwind-coexistence.md), [design system discovery](design-system-discovery.md)
- **Hindsight record**: `proposed-gradual-bootstrap-to-tailwind-migration` and the initiative page “Eventa Servo design system and incremental redesign”

## Goal

Replace Bootstrap with Tailwind CSS v4 gradually, component by component and page by page, in small changes that can be shipped to production independently. Bootstrap and Tailwind must coexist during the migration without visual or functional regressions on existing pages.

Non-goals:

- A big-bang rewrite of all views.
- Changing the visual identity, especially the Esperanto green.
- Migrating the mailer CSS: `mailer.sass` is self-contained and does not import Bootstrap.
- Removing Bootstrap JavaScript before every interaction has an accessible replacement.

## Decisions

The strategy below was discussed and approved on 2026-11-05.

1. **Cascade isolation**: wrap Bootstrap and the application Sass in a low-priority `legacy` cascade layer, disable Tailwind Preflight, and prefix every Tailwind utility with `tw:`.
2. **Build**: use `@tailwindcss/cli` through Yarn, producing a separate `app/assets/builds/tailwind.css` that is chained into the existing `build:css` script. No new gem, no change to Docker or CI.
3. **Pilot**: migrate pagination first, replacing `pagy.series_nav(:bootstrap)` with a Tailwind-based ViewComponent used on real listing pages.
4. **Tokens**: keep the palette, including the Esperanto green and the event timing colours, in CSS custom properties exposed through Tailwind `@theme`. The legacy Sass mirrors the same values temporarily, guarded by a consistency test.
5. **JavaScript**: replace Bootstrap interactions with Stimulus controllers and the native `<dialog>` element. Keep `window.bootstrap` until the last interaction is migrated.
6. **Validation**: component tests, system tests, Lookbook previews, and a manual checklist across `eo`, `en`, `pt_BR` and 375, 768, 1280 px widths.
7. **Event card**: not the first pilot. It already has custom BEM CSS, uses `stretched-link`, and its redesign is still under review. It becomes a later pilot after the pipeline and the first production component are proven.

## Current state

Measured in the repository on 2026-11-05:

| Area | Finding |
|---|---|
| CSS build | `yarn build:css:app` compiles `app/assets/stylesheets/cssbundling.sass.scss` with Sass. `cssbundling-rails` enhances `assets:precompile` with `css:build`, so Docker and CI already run the build. |
| Layouts | `application`, `component_preview` (Lookbook) and `iframe` load `cssbundling` and `application.js`. |
| Cascade | Bootstrap and application Sass are unlayered. Tailwind v4 emits utilities inside `@layer utilities`. Unlayered normal CSS beats layered normal CSS. |
| `!important` | 116 occurrences in `app/assets/stylesheets`, including 64 in `colors.scss`, 32 in `_page.scss` and 8 in `_boxwhite.scss`. There is a global `a { text-decoration: none !important }`. |
| Preflight risk | Inline `image_tag` icons and bullet lists rely on Bootstrap Reboot. Preflight would set `img { display: block }` and remove list styles and padding. |
| Name collisions | Bootstrap and Tailwind share `container`, `border`, `shadow`, `rounded`, `collapse`, `visible`, `table`, `fixed`, and others. |
| Bootstrap JavaScript | 54 `data-bs-*` attributes: 23 toggles (6 dropdown, 7 tooltip, 3 tab, 2 modal, 1 collapse), 16 modal dismiss buttons, 7 placements, 6 targets, 1 focus option. Direct JS use is limited to `Tooltip` and the `shown.bs.modal` event. |
| Indirect dependencies | 98 `@extend` of Bootstrap selectors across several partials, one `media-breakpoint-up` mixin, `pagy.series_nav(:bootstrap)`, and the `.text-bg-*` override. |
| Event card | `Events::CardComponent` uses BEM CSS and only `mb-3` and `stretched-link` from Bootstrap. It is rendered from 3 templates and appears on city, country, continent, past-event and report pages. |
| Devcontainer | `es-design-system-backend-1` mounts this worktree at `/eventaservo` with Ruby 4.0.5, Node 20.20.2 and Yarn 1.22.22. Tailwind is not installed. Selenium is not running. |
| Pagy | Pagy 43.5.6. `pagy.series` and `pagy.page_url(page)` are available for a custom renderer. The gem ships `pagy-tailwind.css`, but it starts with `@import "tailwindcss"`, so it must be adapted rather than imported directly. |

A throwaway Sass file in the devcontainer confirmed that `@layer legacy { @import "bootstrap/scss/bootstrap"; ... }` compiles with the current Sass version and that `@extend .btn` keeps working. The exact visual behaviour still needs the Phase 0 spike.

## Target architecture

### Build pipeline

- Add `@tailwindcss/cli` to `package.json`.
- Add `app/assets/stylesheets/tailwind.css` as the Tailwind entry point.
- Generate `app/assets/builds/tailwind.css` (already ignored by `.gitignore`).
- Chain the build into the existing script:

```json
{
  "scripts": {
    "build:css:tailwind": "tailwindcss -i ./app/assets/stylesheets/tailwind.css -o ./app/assets/builds/tailwind.css --minify",
    "build:css:tailwind:watch": "tailwindcss -i ./app/assets/stylesheets/tailwind.css -o ./app/assets/builds/tailwind.css --watch",
    "build:css": "yarn build:css:assets && yarn build:css:app && yarn build:css:tailwind && yarn build:css:mailer"
  }
}
```

- Add `css_tailwind: yarn build:css:tailwind:watch` to `Procfile.dev`.
- Add `stylesheet_link_tag "tailwind", "data-turbo-track": "reload"` to `application`, `component_preview` and `iframe`, after `cssbundling`.

Because `assets:precompile` already runs `css:build`, Docker, CI and `db:test:prepare` pick up the new build without further changes.

### Tailwind entry point

```css
@layer properties, legacy, theme, base, components, utilities;

@import "tailwindcss/theme.css" layer(theme) prefix(tw);
@import "tailwindcss/utilities.css" layer(utilities) prefix(tw);

@source "../../views";
@source "../../components";
@source "../../helpers";
@source "../../javascript";
@source "../../../test/components/previews";

@theme {
  --color-esperanto-50: #f7faf7;
  --color-esperanto-100: #e5f4e8;
  --color-esperanto-500: #28a745;
  --color-esperanto-600: #1e7145;
  --color-esperanto-900: #202c23;

  --color-event-today: #00a300;
  --color-event-7days: #e3a21a;
  --color-event-30days: #ffc40d;
  --color-event-future: #2d89ef;
  --color-event-past: #c0c0c0;
}
```

Preflight is deliberately omitted. `prefix(tw)` on the explicit imports is shown in the current Tailwind documentation; Phase 0 must confirm that this version supports it. If it does not, the fallback is `@import "tailwindcss" prefix(tw)` plus a minimal Preflight compensation block, documented as a temporary exception.

### Legacy Sass entry point

Keep third-party CSS unlayered so Leaflet, Trix, slim-select and glightbox keep their current behaviour. Wrap Bootstrap and the application Sass in `legacy`:

```scss
$success: #28a745;
$info: #17a2b8;
$badge-font-weight: normal;

@import "@fortawesome/fontawesome-free/scss/fontawesome";
@import "@fortawesome/fontawesome-free/scss/solid";
@import "@fortawesome/fontawesome-free/scss/brands";
@import "@fortawesome/fontawesome-free/scss/regular";

@import "leaflet/dist/leaflet";
@import "leaflet.markercluster/dist/MarkerCluster";
@import "leaflet.markercluster/dist/MarkerCluster.Default";
@import "jquery-ui-dist/jquery-ui";
@import "flag-icons/css/flag-icons";
@import "slim-select/dist/slimselect";
@import "trix/dist/trix";
@import "glightbox/dist/css/glightbox";

@layer properties, legacy, theme, base, components, utilities;

@layer legacy {
  @import "bootstrap/scss/bootstrap";
  @import "colors";
  @import "partials/boxwhite";
  @import "partials/buttons";
  @import "partials/tag_check";
  @import "partials/cards";
  @import "partials/calendar";
  @import "partials/calendar_icon";
  @import "partials/changelog";
  @import "partials/combobox";
  @import "partials/diffy";
  @import "partials/es-lists";
  @import "partials/event-count";
  @import "partials/events";
  @import "partials/flash";
  @import "partials/form";
  @import "partials/maps";
  @import "partials/organizations";
  @import "partials/page";
  @import "partials/prie";
  @import "partials/profile";
  @import "partials/reklamoj";
  @import "partials/toolbar";
  @import "partials/typography";
  @import "partials/direct_uploads";
  @import "partials/actiontext";

  a,
  a:hover,
  a:focus,
  a:active,
  a:visited {
    text-decoration: none !important;
  }
}
```

The same `@layer properties, legacy, theme, base, components, utilities;` statement goes at the top of the Tailwind entry point. `properties` is Tailwind's internal layer for registered custom properties; declaring it first keeps its defaults below the utilities. Repeating the full order in both files makes the result independent of stylesheet load order.

### Why this isolation

- Normal declarations: later layers win. Tailwind utilities in `utilities` beat `legacy` normal declarations, which removes the need for `!` on most utilities.
- Unlayered third-party CSS still beats Tailwind normal declarations. That is intentional: it protects Leaflet, Trix and similar libraries.
- Important declarations reverse the layer order. The 116 legacy `!important` rules continue to win over Tailwind utilities, including utilities marked `!`. They are treated as explicit exceptions, not silently overridden.

### `!important` policy

- Do not add new `!important` rules to the legacy layer.
- For the global link reset, add narrowly scoped exceptions in the legacy file (for example, a future `.prose a { text-decoration: underline !important; }`) rather than removing the global reset immediately.
- New components use Tailwind tokens, not the legacy `.fg-color-*` / `.bg-color-*` helpers, so the remaining `!important` rules do not affect them.
- Removing legacy `!important` rules is a separate cleanup phase, after their call sites are migrated and visually validated.

### Class detection

Tailwind v4 scans every text file that is not gitignored, which already covers `.erb`, `.rb` (ViewComponents, helpers and Lookbook previews) and `.js`. The explicit `@source` entries above make the scope predictable and avoid scanning `docs/`, `db/` and generated assets.

Rules:

- Never build utility names by interpolation. Use maps of complete class strings in helpers and components.
- Add a canary class that exists only in a Lookbook preview and assert that it appears in the generated `tailwind.css`.
- Keep the `tw:` prefix in the canary so the prefix configuration is also tested.

Example helper:

```ruby
EVENT_BORDER_CLASS = {
  today: "tw:border-l-event-today",
  soon: "tw:border-l-event-7days",
  later: "tw:border-l-event-30days",
  future: "tw:border-l-event-future",
  past: "tw:border-l-event-past"
}.freeze
```

### Tokens and the Esperanto green

- CSS custom properties are the temporary single source of truth.
- Tailwind reads them through `@theme`.
- The legacy Sass mirrors the same values and a test compares the key hex values (`#28a745`, `#1e7145`, `#e5f4e8`, `#f7faf7`, `#202c23`) plus the five event timing colours.
- The mirror is deleted in Phase 6, when Bootstrap leaves.

### JavaScript

| Bootstrap behaviour | Replacement | Notes |
|---|---|---|
| Modals | Native `<dialog>` + Stimulus | Focus trap, Esc and backdrop are native. Handle focus return, backdrop click, `turbo:before-cache`, `aria-labelledby`, and the timezone modal's custom focus behaviour. |
| Dropdowns | Stimulus controller | `aria-expanded`, `aria-controls`, `role="menu"`/`menuitem`, arrow keys, Home/End, Esc, outside click. |
| Tabs | Stimulus controller | ARIA tabs pattern with `tablist`, `tab`, `tabpanel`, arrow keys and `aria-selected`. |
| Tooltips | Stimulus controller | `aria-describedby`, `role="tooltip"`, show on hover/focus, close on Esc. Consider Floating UI only if positioning becomes complex. |
| Collapse / navbar | Stimulus toggle | `aria-expanded` and `aria-controls`. |
| Alert dismiss | Small Stimulus controller | Trivial. |

Keep `import * as bootstrap` and `window.bootstrap` until the last interaction is migrated. Then remove the `bootstrap` package and, if unused, `@popperjs/core`.

## Phases

### Phase 0 — Cascade and build spike

- Branch: throwaway spike, not merged.
- Add the Tailwind build, the `legacy` layer, the `tw:` prefix and the no-Preflight configuration.
- Add a Lookbook-only canary preview with elements that combine legacy classes and Tailwind utilities on the same property, a link that needs `tw:underline`, an inline image, a bullet list and a pagination-like block.
- Run the build and `assets:precompile` in the devcontainer.
- Compare control pages at 375, 768 and 1280 px in `eo`, `en` and `pt_BR`: home, a city listing, an event detail page, an organisation page with tabs, the report form and the login page.
- Add a system test that reads `getComputedStyle` for the canary elements.

Exit criteria: build passes in the devcontainer and in `assets:precompile`; the canary system test passes; no visual change on control pages; the `prefix()` + parts-import question is answered.

### Phase 1 — Infrastructure

- Add the Tailwind build, entry point, tokens, layer declaration and layout links.
- Add the build scripts, `Procfile.dev` entry and the detection canary test.
- Do not use Tailwind utilities in production markup yet.

Exit criteria: Tailwind CSS is served in development and production, all existing pages are visually unchanged, and CI is green.

### Phase 2 — Pagination pilot

- Create a Tailwind-based pagination ViewComponent (or partial) fed by `pagy.series`, `pagy.prev`, `pagy.next` and `pagy.page_url`.
- Replace `pagy.series_nav(:bootstrap)` in `app/views/shared/_pagination.html.erb`.
- Add a Lookbook preview with first page, middle page, last page, gaps and a single page.
- Add system tests for keyboard navigation and `aria-current="page"`.

Exit criteria: pagination works on city, country, continent and past-event listings in all three locales and three widths; the Pagy Bootstrap dependency is gone from that helper.

### Phase 3 — Shared components

Order:

1. Buttons.
2. Badges and tags.
3. Flash messages and alerts.
4. Form controls.
5. Cards.
6. Navbar pieces.

Each component gets a ViewComponent (when reusable), a Lookbook preview and a component test. Replace the corresponding `@extend`-based Sass as part of the same change.

### Phase 4 — JavaScript interactions

Order:

1. Alert dismiss.
2. Collapse / navbar.
3. Dropdowns.
4. Tabs.
5. Modals.
6. Tooltips.

One interaction per pull request, each with keyboard and focus tests. Bootstrap JavaScript stays installed until the last item is migrated.

### Phase 5 — Pages

Order:

1. Low-traffic static pages: privacy, about, error pages.
2. Home.
3. Listings: city, country, continent, past events.
4. Event detail.
5. Forms, authentication and profile.
6. Organisations.
7. Admin.

One page per pull request where possible. The Bootstrap usage budget must go down in each migrated area.

### Phase 6 — Removal

- Replace the remaining Pagy Bootstrap rendering.
- Replace the remaining 98 `@extend` declarations and the `media-breakpoint-up` mixin.
- Remove the `.text-bg-*` override and the Bootstrap `$success` / `$info` variables.
- Remove the Bootstrap Sass import, the `bootstrap` package, `@popperjs/core` if unused, `window.bootstrap`, the Bootstrap JavaScript import and the `legacy` layer.
- Delete the legacy `!important` rules that are no longer needed.
- Audit `postcss.config.js`: it appears to be leftover configuration and is not used by the current build.

Exit criteria: no `data-bs-*` attributes, no `@extend` of Bootstrap selectors, no Bootstrap dependency in `package.json`, and a green test suite.

## Phase 0 spike results (2026-11-05)

Status: **GO** for Phase 1.

Environment: devcontainer `es-design-system-backend-1`, Ruby 4.0.5, Node 20.20.2, `@tailwindcss/cli` 4.3.4.

### Build

- `yarn build:css` and `SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile` pass.
- The Tailwind build is chained into `build:css`, so `css:build` and `assets:precompile` pick it up automatically.
- `source(none)` with explicit `@source` entries works; the build no longer scans `docs/`.
- Outputs: `app/assets/builds/tailwind.css` (minified, ~1.1 KB with the canary) and `app/assets/builds/cssbundling.css`.

### Cascade and prefix

- `@import "tailwindcss/theme.css" layer(theme) prefix(tw)` and `@import "tailwindcss/utilities.css" layer(utilities) prefix(tw) source(none)` work in Tailwind 4.3.4.
- The `tw:` prefix is applied to utilities and to the generated CSS custom properties (`--tw-color-*`). `@theme` entries are still written as `--color-*`.
- Tailwind 4.3.4 emits an internal `properties` layer. The validated global order is `properties, legacy, theme, base, components, utilities`.
- Preflight stays disabled; the canary confirms inline images and bullet lists keep their Bootstrap-era rendering.
- The legacy `!important` link reset still wins over `tw:underline`; a scoped `.canary-prose a` exception in the legacy layer is required, as planned.

### Tests

- `bin/rails test`: 977 runs, 3415 assertions, 0 failures, 0 errors.
- `SELENIUM_REMOTE=true bin/rails test:system`: 7 runs, 18 assertions, 0 failures.
- `bundle exec standardrb` on the new Ruby files: clean.
- The canary test injects the canary markup into a real page and asserts computed styles for `box-white` + `tw:bg-[#ff0000]`, `container` + `tw:p-0`, the link exception, inline image display, list style, event border colour, `d-flex`, and `tw:flex`.

### Visual validation

- 63 screenshots: home, city, country, event detail, organisation, login and privacy in `eo`, `en`, `pt_BR` at 375, 768 and 1280 px.
- City, country, privacy and organisation pages are pixel-identical before/after.
- The only differences are dynamic content: home-page ad banners, the Leaflet map tiles on the event page at 1280 px, and the reCAPTCHA badge on the login page. No CSS or layout differences.
- Lookbook preview: `/lookbook/inspect/ui/tailwind_canary/default`.

### Findings and corrections

- The earlier plan listed the layer order as `legacy, theme, base, components, utilities`; the validated order is `properties, legacy, theme, base, components, utilities`.
- The canary component, preview and test are temporary Phase 0 artifacts. The cascade test can become a permanent guard in Phase 1; the component and preview should be removed or promoted deliberately.
- The spike branch is not merged; Phase 1 starts from the approved architecture.

## Validation

### Per pull request

- Component test for markup and behaviour.
- Lookbook preview with the relevant states.
- System test for any interaction.
- `bundle exec standardrb` for Ruby changes.
- Asset build in the devcontainer.
- Manual checklist: `eo`, `en`, `pt_BR` × 375, 768, 1280 px on the affected pages.

### Automated guards

- **Detection canary**: a class used only in a Lookbook preview must appear in the built CSS.
- **Cascade canary**: a system test asserts that a `tw:` utility wins over a legacy class on the same element.
- **Bootstrap usage budget**: a script counts `data-bs-*` attributes and known Bootstrap component classes per directory, stores a baseline, and fails CI when the count increases.
- **Token consistency**: a test compares the Tailwind `@theme` values with the legacy Sass variables for the Esperanto green and the five event timing colours.

### Environment

Run builds and tests in the devcontainer:

```bash
docker exec -it es-design-system-backend-1 bash
cd /eventaservo
yarn build:css
bin/rails test
```

System tests need the Selenium service:

```bash
docker compose up -d selenium
SELENIUM_REMOTE=true bin/rails test:system
```

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Unlayered legacy normal CSS wins over Tailwind utilities | Wrap first-party legacy CSS in `legacy`; keep third-party CSS unlayered on purpose. |
| Legacy `!important` wins over utilities | Treat the 116 rules as explicit exceptions; add narrow overrides; do not add new ones. |
| Preflight changes images, lists and headings | Keep Preflight disabled until Bootstrap is removed. |
| `@extend` breaks the Sass build | Migrate partial by partial; keep the build green in every PR. |
| `prefix()` with explicit CSS imports is unsupported | Phase 0 verifies it; fallback is the main import plus a documented Preflight compensation block. |
| Dynamic class names in Ruby are not detected | Use maps of complete strings; add the detection canary. |
| Visual regressions across locales and viewports | 3 × 3 manual checklist per stage; consider automated visual regression after the pilot. |
| Large surface area (191 views, 123 files with Bootstrap classes) | Component-first order, page-by-page later, and a ratcheting usage budget. |
| System tests require Selenium | Start the `selenium` service and set `SELENIUM_REMOTE=true`; document it in the PR template or test docs. |

## Open follow-ups

- Confirm `prefix(tw)` with `tailwindcss/theme.css` and `tailwindcss/utilities.css` in the installed v4 version.
- Decide whether to adopt automated visual regression (Playwright or BackstopJS) after the pagination pilot.
- Decide whether to keep explicit `@source` entries or rely on automatic detection once the layout is stable.
- Audit and remove `postcss.config.js` if it is confirmed to be unused.
- Plan the removal of the legacy `!important` rules after their call sites are migrated.
