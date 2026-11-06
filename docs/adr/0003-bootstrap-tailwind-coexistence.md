# ADR-0003: Bootstrap and Tailwind CSS coexistence during the incremental migration

- **Status**: Accepted (strategy); implementation pending
- **Date**: 2026-11-05
- **Tracking issue**: [#1514](https://github.com/eventaservo/eventaservo/issues/1514)
- **Related**: [Tailwind migration plan](../tailwind-migration-plan.md), [design system discovery](../design-system-discovery.md)

## Context

Eventa Servo is a Rails application styled with Bootstrap 5.3, built from Sass through `cssbundling-rails`. The front end also uses Stimulus, Turbo, ViewComponent and Lookbook. The project is starting an incremental design-system effort and wants to replace Bootstrap with Tailwind CSS v4 over time, shipping small changes to production instead of a single rewrite.

Two constraints dominate the design:

1. **Cascade**: Bootstrap and the application Sass are unlayered, while Tailwind v4 emits utilities inside `@layer utilities`. Unlayered normal CSS wins over layered normal CSS regardless of specificity. The application also has 116 `!important` declarations and a global `a { text-decoration: none !important }`.
2. **Resets and JavaScript**: Tailwind Preflight would change image display and list styles that the current pages depend on. Bootstrap JavaScript currently drives modals, dropdowns, tabs, tooltips, the navbar collapse and alert dismissal.

A throwaway build in the development container confirmed that Sass accepts `@layer legacy { @import "bootstrap/scss/bootstrap"; ... }` and that `@extend .btn` keeps working across the layer boundary.

## Decision

Adopt a coexistence strategy with the following elements:

1. **Separate build**: Tailwind v4 is compiled by `@tailwindcss/cli` through Yarn into `app/assets/builds/tailwind.css`. The build is chained into the existing `build:css` script, so `assets:precompile`, Docker and CI pick it up without changes.
2. **Prefix and no Preflight**: every Tailwind utility uses the `tw:` prefix. Preflight is omitted while Bootstrap remains.
3. **Legacy layer**: Bootstrap and the first-party application Sass are wrapped in a low-priority `legacy` cascade layer. Third-party CSS (Leaflet, Trix, slim-select, glightbox) stays unlayered. Layer order is declared identically in both entry points: `properties, legacy, theme, base, components, utilities` (`properties` is Tailwind's internal layer for registered custom properties).
4. **Tokens**: the Esperanto green and the event timing colours live in CSS custom properties exposed through Tailwind `@theme`. The legacy Sass mirrors the values temporarily, with a consistency test.
5. **Pilot**: pagination is the first production component, replacing `pagy.series_nav(:bootstrap)`.
6. **JavaScript**: Bootstrap interactions are replaced one at a time by Stimulus controllers and the native `<dialog>` element. Bootstrap JavaScript remains installed until the last interaction is migrated.
7. **Validation**: component tests, system tests, Lookbook previews, a 3 × 3 manual checklist (`eo`, `en`, `pt_BR` × 375, 768, 1280 px), a class-detection canary, a cascade canary and a ratcheting Bootstrap usage budget.

## Consequences

### Positive

- Existing pages keep their appearance while Tailwind utilities are introduced, because the legacy layer preserves the current reset and component styles.
- Tailwind utilities beat first-party legacy normal declarations predictably, without requiring `!important` on every utility.
- Third-party CSS keeps its current precedence, reducing the risk of breaking maps, editors and select widgets.
- The build integrates with the existing Yarn and `assets:precompile` pipeline, with no new gem or CI step.
- Small, production-ready increments remain possible: infrastructure, pilot, components, interactions, pages, removal.

### Negative / trade-offs

- The `tw:` prefix makes the markup more verbose and must be applied consistently.
- The 116 legacy `!important` declarations remain an explicit exception list; some utilities will need scoped overrides or `!`.
- Wrapping the legacy CSS in a cascade layer is a global change. It requires a spike and visual validation before the first production component.
- The legacy Sass and the Tailwind theme duplicate token values until Bootstrap is removed.
- Two CSS builds and two watch processes must be kept in sync in development.
- The migration is long: 191 views and 123 files currently contain Bootstrap classes.

### Validation

Phase 0 (2026-11-05) validated the build, the `tw:` prefix with explicit imports, `source(none)` with explicit `@source` entries, the `properties, legacy, theme, base, components, utilities` layer order, the cascade canary and the 3 × 3 visual checklist. The full suite passed (977 tests) and the seven system tests passed. See [the plan](../tailwind-migration-plan.md#phase-0-spike-results-2026-11-05) for evidence.

### Follow-ups

- Verify in Phase 0 that the installed Tailwind v4 version supports `prefix(tw)` with the explicit `theme.css` and `utilities.css` imports.
- Decide after the pilot whether to add automated visual regression.
- Remove the legacy layer, the token mirror and the Bootstrap dependencies in the final phase.
