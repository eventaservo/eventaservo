# ADR-0002: Nearby Cities Event Discovery on City View

- **Status**: Proposed
- **Date**: 2026-11-02
- **Issue**: [#1323](https://github.com/eventaservo/eventaservo/issues/1323)
- **Pull Request**: [#1330](https://github.com/eventaservo/eventaservo/pull/1330)

## Context

In Eventa Servo, the city discovery page (`/events/by_city` or `/:continent/:country/:city`) originally filtered events by matching the exact city name string (`events.city`). Consequently, community members visiting a city page missed relevant events happening in closely neighboring towns or across borders (such as Copenhagen, Denmark and Malmö, Sweden, separated by only 28 km across the Øresund bridge).

Jacob Nordfalk submitted PR #1330 proposing a 50 km radius to discover and display nearby events. An analysis of production data revealed that 99.95% of in-person events and 99.74% of physical cities have valid geographical coordinates (`latitude` and `longitude`), demonstrating high feasibility for distance-based discovery. A 50 km radius accommodates regional travel habits in Esperanto communities while preventing over-broad discovery lists. Furthermore, the code required overhaul to meet project standards: strict English naming across all code, symbols, and URL query parameters (`?nearby=0`), query object design, active filter persistence, antimeridian geometry wrapping, and compliance with `TEST_ARCHITECTURE.md`.

## Decision

We adopt a two-stage spatial search with caching for nearby city events in the by-city view:

1. **Default Discovery Radius (50 km)**:
   - Configured as `DEFAULT_RADIUS_KM = 50` in `Events::NearbyCitiesQuery`, accepting an optional `radius_km:` parameter for testability and flexibility.
   - UI copy and badges remain generic (`Proksima` / `Nearby` / `Próximo`) without hardcoding numbers in translated strings.

2. **English Naming & Preference Persistence via Cookie**:
   - All code, method names, variable names, documentation, and technical endpoints are strictly in English.
   - User preference for nearby events is stored in a 2-week cookie (`cookies[:nearby]`), following an opt-out model (shown by default, hidden when `cookies[:nearby] == "0"`).
   - Toggling is handled via dedicated technical endpoints `/nearby/on` and `/nearby/off`, redirecting back to the referring page. This avoids cluttering URLs with query parameters and eliminates the need to propagate state across filter badges.

3. **Two-Stage Spatial Query (`Events::NearbyCitiesQuery`)**:
   - **Reference Point**: The target city's representative coordinate is determined by its first event with valid coordinates (`Event.by_city(...).by_country_id(...).where.not(latitude: nil).order(:id).pick(:latitude, :longitude)`).
   - **Stage 1 (SQL Bounding Box)**: Utilizes a composite index on `events(latitude, longitude)` for fast candidate pruning.
   - **Antimeridian Handling (±180°)**: If the bounding box crosses the antimeridian line, the longitude predicate splits into an `OR` clause covering both ranges `[-180, wrapped_max]` and `[wrapped_min, 180]`, preventing false negatives for Pacific/oceanic cities.
   - **Stage 2 (Haversine Refinement)**: Uses `Geocoder::Calculations.distance_between` to filter out corner candidates from the bounding box that exceed `radius_km`.
   - **12-Hour Versioned Cache**: Cached via `Rails.cache.fetch("events/nearby_cities/v2/#{country_id}/#{city.normalized}/#{radius_km}", expires_in: 12.hours)`.

4. **Scope & View Constraints**:
   - Nearby events are displayed **only** on the future/today cards listing (`@card_view`, i.e., `vidmaniero: "kartaro"` or `"kartoj"`).
   - Past events (`pasintaj=1`) and map view (`mapo`) strictly remain focused on the target city only.
   - Query preserves timezone-awareness on `origin/main` using `venontaj(current_timezone)`.

5. **Filter & State Independence**:
   - Because preference is cookie-persisted, browsing filters (`periodo`, `o`, `s`, `t`) operate independently without needing to propagate `nearby` parameters through badges or links.

6. **Database Schema**:
   - Includes a composite index on `events(latitude, longitude)` for efficient spatial bounding box range queries.

## Consequences

### Positive
- Substantially improves event discovery for users in metropolitan regions and border areas (e.g., Copenhagen/Malmö, border cities in Central Europe, neighboring Brazilian cities) within a realistic travel radius of 50 km.
- High query performance: fast indexed SQL bounding box combined with in-memory Haversine refinement and 12-hour caching.
- Zero filter disruption: users can refine by category, organization, or timeframe without losing nearby toggle state or vice-versa.
- Clean URLs without query parameter pollution; preference persists across sessions and navigation.
- Mathematically robust handling of edge cases, including cities near the ±180° antimeridian.

### Negative / Trade-offs
- If a city has no events with coordinates, the query gracefully falls back to displaying only the target city's exact events (affecting < 0.3% of cities based on production data).
- First event coordinate is assumed as the city center; very large sprawling metropolitan zones (> 50 km across) treat all city events equally based on this single anchor.
