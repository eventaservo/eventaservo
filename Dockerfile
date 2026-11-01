################
# Base (Runtime)
################

FROM ruby:4.0.7-slim-trixie AS base

WORKDIR /eventaservo

# Install minimal tools needed to add external repositories
RUN apt update && apt install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/apt/keyrings

# Adds PostgreSQL repository for pg_dump 18 client tools
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ trixie-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Install runtime-only packages
RUN apt update && apt install -y --no-install-recommends \
  imagemagick \
  libpq5 \
  libvips42 \
  poppler-utils \
  postgresql-client-18 \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

##################
# Build-Base
##################

FROM base AS build-base

# Adds NodeJS repository
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install build compilers, development headers, git, and nodejs
RUN apt update && apt install -y --no-install-recommends \
  g++ \
  gcc \
  git \
  libavahi-compat-libdnssd-dev \
  libmagick++-dev \
  libpq-dev \
  libssl-dev \
  libyaml-dev \
  make \
  nodejs \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn and Redocly CLI
RUN npm install -g yarn @redocly/cli@1.0.2

######################
# Builder (Production)
######################

FROM build-base AS builder

# Bundler configuration
RUN echo "gem: --no-document" >> ~/.gemrc
RUN bundle config set without development test && \
  bundle config set deployment true && \
  bundle config set frozen true

COPY Gemfile Gemfile.lock ./
RUN bundle install --retry=3

COPY package.json yarn.lock ./
RUN yarn install

# Download GeoLite2 offline IP geocoding database
# NOTE: --insecure is used because GitHub raw URLs can have SSL issues
# in Docker BuildKit environments. The database is public data (CC BY-SA 4.0)
# and is verified by MaxMind's SHA256 checksum.
RUN curl -fSL --retry 5 --retry-delay 15 --connect-timeout 60 --insecure \
  -o /eventaservo/GeoLite2-City.mmdb \
  https://raw.githubusercontent.com/P3TERX/GeoLite.mmdb/download/GeoLite2-City.mmdb

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN bundle exec rails assets:precompile

RUN redocly build-docs openapi/v2.yaml -o public/docs/api/v2/index.html

# Prune build artifacts not needed at runtime
RUN rm -rf node_modules tmp/cache

############
# Production
############

FROM base AS production

ARG ENVIRONMENT=production
ENV RAILS_ENV=${ENVIRONMENT}
ENV NODE_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ARG GOOGLE_MAPS_KEY
ARG IPINFO_KEY
ENV GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
ENV IPINFO_KEY=${IPINFO_KEY}
ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_DEPLOYMENT="1"

# Copy precompiled gems and application code from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /eventaservo /eventaservo

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]

CMD bin/rails db:migrate; bundle exec thrust bin/rails server -b 0.0.0.0 -p 3000

#############
# Staging
#############

FROM production AS staging

#############
# Development
#############

FROM build-base AS development

ENV RAILS_ENV=development
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Install tools for development (including btop, ping, telnet, vim moved from base)
RUN apt update \
  && apt install -y --no-install-recommends \
  btop \
  chromium-driver \
  fish \
  gh \
  iputils-ping \
  jq \
  openssh-client \
  ripgrep \
  sudo \
  telnet \
  vim \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Adds a non-root user
RUN useradd rails --create-home --shell /usr/bin/zsh && \
  echo 'rails:password' | chpasswd && \
  adduser rails sudo && \
  newgrp sudo && \
  echo 'rails ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  chown rails:rails /eventaservo -R
USER rails

RUN gem install htmlbeautifier

# Git and gh configuration
RUN git config --global --add safe.directory /eventaservo && \
  gh auth setup-git 2>/dev/null || true

# Installs Oh-My-Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions bundler)/" ~/.zshrc

EXPOSE 3000

CMD sleep infinity
