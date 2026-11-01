# ADR-0001: Multi-stage Docker build for minimal production images

- **Status**: Proposed
- **Date**: 2026-11-01
- **Issue**: [#1202](https://github.com/eventaservo/eventaservo/issues/1202)

## Context

The previous `Dockerfile` relied on a single shared `base` image that installed:
- Build compilers (`gcc`, `g++`, `make`) and development headers (`libmagick++-dev`, `postgresql-server-dev-all`).
- Interactive developer and debugging utilities (`btop`, `vim`, `iputils-ping`, `telnet`).
- Node.js, Yarn, and the complete `node_modules/` tree (~200MB+), even though Rails serves static precompiled assets in production.

This resulted in bloated production images, longer pull/deployment cycles, and an unnecessarily broad security attack surface with active compilers and debug tools in the production container.

## Decision

We adopt a multi-stage Docker build that strictly isolates build-time dependencies from the runtime environment:

1. **`base` (Minimal Runtime)**:
   - Inherits from `ruby:4.0.7-slim-trixie`.
   - Contains only runtime dependencies: `ca-certificates`, `curl`, `gnupg`, `imagemagick` (CLI), `libvips42`, `poppler-utils`, `postgresql-client-18` (for database dumps), `libpq5` (runtime client library for `pg`), and `tzdata`.
   - Free of compilers, build headers, Node.js, and interactive debug tools.

2. **`builder` (Build Environment)**:
   - Extends `base` and installs native build toolchains (`gcc`, `g++`, `make`, `git`, `libpq-dev`, `libssl-dev`, `libyaml-dev`, `zlib1g-dev`, `libavahi-compat-libdnssd-dev`).
   - Installs Node.js and Yarn for asset compilation and Redocly for API v2 documentation generation.
   - Executes `bundle install` without development/test gems.
   - Executes `yarn install`, `bundle exec rails assets:precompile`, and `redocly build-docs`.
   - Prunes temporary build artifacts, `node_modules`, and asset cache directories.

3. **`production` (Enxuta / Runtime)**:
   - Extends `base`.
   - Copies `/usr/local/bundle` from `builder`.
   - Copies compiled application code and static assets (`public/assets/`, `app/assets/builds/`, `public/docs/`, `GeoLite2-City.mmdb`) from `builder`, strictly excluding `node_modules/`.
   - Runs under Thruster + Puma (`bundle exec thrust bin/rails server`).

4. **`staging`**:
   - Extends `production` (`FROM production AS staging`) to preserve 100% parity with production.

5. **`development`**:
   - Extends `build-base` (preserving compilers, Node.js, and Yarn needed for local compilation and asset watching).
   - Installs developer tools: `btop`, `vim`, `iputils-ping`, `telnet`, `zsh`, `sudo`, `chromium-driver`, `fish`, `gh`, `jq`, `openssh-client`, `ripgrep`.
   - Configures the `rails` user and Oh-My-Zsh (single-layer instruction).

## Consequences

### Positive
- Substantially reduced production and staging image footprint (hundreds of MBs saved from `node_modules`, compiler toolchains, and server dev packages).
- Reduced attack surface in production (no compilers, no packet analyzers, no debuggers).
- Faster image pull and deploy times in CI/CD and deployment servers.
- Full parity between Staging and Production.
- Developer experience remains intact in `development` target with all existing tools.

### Negative / Trade-offs
- Dockerfile maintenance requires keeping build-time and runtime libraries clearly separated.
- Any new gem requiring native compilation must ensure runtime shared libraries (`.so`) are in `base` and header packages (`-dev`) are in `builder`.
