# Eventa Servo design system discovery

## Purpose and working approach

- Establish a shared design system for the public and administrative areas, allowing for their different needs.
- Use ViewComponent and Lookbook; assess compatible versions before installation or upgrades.
- Review real pages and components together, working incrementally and releasing small changes to production.
- Record decisions here as they are made; visual explorations are proposals until approved.
- Perform development in the repository's devcontainer, which provides the project's Ruby and dependencies.

## Agreed visual direction

- Direction D: clear, functional and information-focused.
- Palette 01, “Herança Esperanto”: retain the application's established green identity, with light backgrounds and a darker green for prominent elements.
- The current application defines Esperanto green as `#28a745` and also uses `#00a300`. The selected palette study includes `#1e7145`, `#28a745`, `#e5f4e8`, `#f7faf7` and `#202c23`; their final roles and accessible combinations remain to be validated.

## Revised first area of work

- First establish ViewComponent and Lookbook, then extract the existing event card into a component while preserving its current appearance and behavior. Modernize its visual design in a later step.
- Use the extracted component at all existing event card call sites, including past listings and event reports. Make Lookbook available in development initially.
- Initial implementation installs ViewComponent 4.23.0 and Lookbook 2.3.15 and exposes the event card preview at `/lookbook/inspect/events/card/default` in development. The preview uses the first event in the development database; seed it if no events exist. The component delegates to the original card partial to preserve its current markup.
- Component previews use a minimal layout with the application assets, without the application navigation or footer.
- Start with a simple, elegant redesign of the event card used on city listings, such as Copenhagen. The user considers the event detail page too critical for a significant initial change.
- The existing `events/card` partial displays a title, flag, organizations, badges and tags, date and time, location, and description when applicable. It also handles cancellation and popular events. Determine which of these are present in the specific listing and preserve their behavior when designing the component.
- The first redesign should be modest in scope. Its precise visual treatment and component boundaries remain open.

## Deferred exploration

- Event detail page: the **Informoj** block, using event `57a626` as a concrete example, is deferred.
- The user finds the current block dated and wants to rework it; the desired layout and content hierarchy remain open for discussion.
- The current template can display a website, email, address and map, participants, administrator or organizations, and uploader information. Availability depends on event data and conditions.
- Preserve existing behavior as a working assumption, subject to the user's decisions during review.

## Next step

Decide the first extraction's scope and Lookbook availability, then plan the installation and event card component. Visual alternatives come later.
