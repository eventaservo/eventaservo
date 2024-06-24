FROM ruby:3.2.2-bookworm as base

WORKDIR /eventaservo

# Adds NodeJS and Yarn repositories
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt update && apt install -y \
  btop \
  g++ \
  gcc \
  htop \
  imagemagick \
  iputils-ping \
  libavahi-compat-libdnssd-dev \
  libmagick++-dev \
  libssl-dev \
  make \
  nodejs \
  poppler-utils \
  postgresql-server-dev-all \
  rclone \
  telnet \
  vim \
  zlib1g-dev \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Bundler
RUN gem install bundler:2.4.6

# Yarn
RUN npm install -g yarn
COPY package.json yarn.lock ./
RUN yarn install




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

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

RUN bundle exec rails assets:precompile

RUN npx @redocly/cli build-docs openapi/v2.yaml -o public/docs/api/v2/index.html

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]

CMD bundle exec rails db:migrate; bundle exec rails server -b 0.0.0.0 -p 3000





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

COPY Gemfile Gemfile.lock ./
RUN bundle install --retry=3

# Git configuration
RUN git config --global --add safe.directory /eventaservo

# Installs Oh-My-Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions)/" ~/.zshrc

# Installs Graphite
RUN npm install -g @withgraphite/graphite-cli@stable

EXPOSE 3000

CMD sleep infinity
