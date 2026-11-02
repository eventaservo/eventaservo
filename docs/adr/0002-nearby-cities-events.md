# ADR-0002: Nearby Cities Event Discovery on City View

- **Status**: Proposed
- **Date**: 2026-11-02
- **Issue**: [#1323](https://github.com/eventaservo/eventaservo/issues/1323)
- **Pull Request**: [#1330](https://github.com/eventaservo/eventaservo/pull/1330)

## Context

In Eventa Servo, the city discovery page (`/events/by_city` or `/:continent/:country/:city`) originally filtered events by matching the exact city name string (`events.city`). Consequently, community members visiting a city page missed relevant events happening in closely neighboring towns or across borders (such as Copenhagen, Denmark and Malmö, Sweden, separated by only 28 km across the Øresund bridge).

Jacob Nordfalk submitted PR #1330 proposing a 50 km radius to discover and display nearby events. An analysis of production data revealed that 99.95% of in-person events and 99.74% of physical cities have valid geographical coordinates (`latitude` and `longitude`), demonstrating high feasibility for distance-based discovery. However, to better accommodate regional travel habits in Esperanto communities, the radius needs adjustment to 120 km. Furthermore, the code required overhaul to meet project standards: strict English naming across all code, symbols, and URL query parameters (`?nearby=0`), query object design, active filter persistence, antimeridian geometry wrapping, and compliance with `TEST_ARCHITECTURE.md`.

## Decision

We adopt a two-stage spatial search with caching for nearby city events in the by-city view:

1. **Default Discovery Radius (120 km)**:
   - Configured as `DEFAULT_RADIUS_KM = 120` in `Events::NearbyCitiesQuery`, accepting an optional `radius_km:` parameter for testability and flexibility.
   - UI copy and badges remain generic (`Proksima` / `Nearby` / `Próximo`) without hardcoding numbers in translated strings.

2. **English Naming & URL Conventions**:
   - All code, method names, variable names, documentation, and URL parameters are strictly in English.
   - The query parameter for toggling nearby events is `nearby` (e.g., `?nearby=0` to hide nearby events, omitted or `?nearby=1` to show them).

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

5. **Filter Preservation**:
   - The nearby toggle link preserves all existing URL query parameters (`params.permit(...).merge(nearby: ...)`), preventing filter loss (e.g., preserving `periodo`, `o`, `s`, `t`).

6. **Database Schema**:
   - Includes a composite index on `events(latitude, longitude)` for efficient spatial bounding box range queries.

## Consequences

### Positive
- Substantially improves event discovery for users in metropolitan regions and border areas (e.g., Copenhagen/Malmö, border cities in Central Europe, neighboring Brazilian cities) within a realistic travel radius of 120 km.
- High query performance: fast indexed SQL bounding box combined with in-memory Haversine refinement and 12-hour caching.
- Zero filter disruption: users can refine by category, organization, or timeframe without losing nearby toggle state or vice-versa.
- Clean English API and URL surface (`?nearby=0`).
- Mathematically robust handling of edge cases, including cities near the ±180° antimeridian.

### Negative / Trade-offs
- If a city has no events with coordinates, the query gracefully falls back to displaying only the target city's exact events (affecting < 0.3% of cities based on production data).
- First event coordinate is assumed as the city center; very large sprawling metropolitan zones (> 120 km across) treat all city events equally based on this single anchor.
