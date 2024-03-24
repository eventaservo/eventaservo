# FROM mcr.microsoft.com/devcontainers/ruby:1-3.2-bookworm

# # Install Rails
# RUN su vscode -c "gem install rails webdrivers"
# RUN su vscode -c "/usr/local/rvm/bin/rvm fix-permissions"

# # Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# # The value is a comma-separated list of allowed domains
# ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# # [Optional] Uncomment this section to install additional OS packages.
# # RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
# #     && apt-get -y install --no-install-recommends <your-package-list-here>

# # [Optional] Uncomment this line to install additional gems.
# # RUN su vscode -c "gem install <your-gem-names-here>"

# # [Optional] Uncomment this line to install global node packages.
# # RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
# # RUN bundle install

FROM ruby:3.2-bookworm

# Adds NodeJS and Yarn repositories
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y \
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
  && rm -rf /var/lib/apt/lists/*

# Sets environment variables
ENV RAILS_ENV=development
ENV DB_HOST=db
ENV DB_USERNAME=postgres
ENV DB_PASSWORD=postgres

# Bundler
RUN gem install bundler:2.4.6
WORKDIR /eventaservo
COPY Gemfile Gemfile.lock ./
RUN bundle install --retry=3

# YARN
RUN npm install -g yarn
RUN yarn set version 3.2.1
COPY .yarnrc.yml ./
COPY package.json yarn.lock ./
RUN yarn install

# Graphite.dev
RUN npm install -g @withgraphite/graphite-cli@stable

# EXPOSE 3000

# ENTRYPOINT [ "./entrypoint.sh" ]

# CMD bundle exec rails db:migrate; bundle exec rails server -b 0.0.0.0 -p 3000
