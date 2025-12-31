FROM ruby:3.4.7-bookworm as base

WORKDIR /eventaservo

# Adds NodeJS and Yarn repositories
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt update && apt install -y --no-install-recommends \
  btop \
  g++ \
  gcc \
  imagemagick \
  iputils-ping \
  libavahi-compat-libdnssd-dev \
  libmagick++-dev \
  libssl-dev \
  libvips42 \
  make \
  nodejs \
  poppler-utils \
  postgresql-server-dev-all \
  telnet \
  vim \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Yarn
RUN npm install -g yarn





############
# Production
############

FROM base as production

# Sets environment variables
ARG ENVIRONMENT=production
ENV RAILS_ENV=${ENVIRONMENT}
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
ENV IPINFO_KEY=${IPINFO_KEY}

# Bundler
RUN echo "gem: --no-document" >> ~/.gemrc
RUN bundle config set without development test && \
  bundle config set deployment true && \
  bundle config set frozen true

COPY Gemfile Gemfile.lock ./
RUN bundle install --retry=3

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

RUN bundle exec rails assets:precompile

RUN npx @redocly/cli build-docs openapi/v2.yaml -o public/docs/api/v2/index.html

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]

CMD bin/rails db:migrate; bundle exec thrust bin/rails server -b 0.0.0.0 -p 3000





#############
# Staging
#############

FROM production as staging





#############
# Development
#############

FROM base as development

ENV RAILS_ENV=development
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Install tools for development
RUN apt update \
  && apt install -y --no-install-recommends \
  chromium-driver \
  fish \
  sudo \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Install AI Tools
RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g @google/gemini-cli

# Adds a non-root user
RUN useradd rails --create-home --shell /usr/bin/zsh && \
  echo 'rails:password' | chpasswd && \
  adduser rails sudo && \
  newgrp sudo && \
  echo 'rails ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  chown rails:rails /eventaservo -R
USER rails

RUN gem install htmlbeautifier

# Git configuration
RUN git config --global --add safe.directory /eventaservo

# Installs Oh-My-Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions bundler)/" ~/.zshrc

EXPOSE 3000

CMD sleep infinity
