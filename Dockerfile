FROM ruby:3.2-bookworm

WORKDIR /app

# Adds NodeJS and Yarn repositories
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y \
  g++ \
  gcc \
  iputils-ping \
  imagemagick \
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

ARG AMBIENTE=production
# Sets environment variables
ENV RAILS_ENV=${AMBIENTE}
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
ENV IPINFO_KEY=${IPINFO_KEY}

# Bundler
RUN echo "gem: --no-document" >> ~/.gemrc
RUN gem install bundler:2.4.6
RUN if [ "$RAILS_ENV" = "production" ] || [ "$RAILS_ENV" = "staging" ]; then \
  bundle config set without development test && \
  bundle config set deployment true && \
  bundle config set frozen true ; fi

COPY Gemfile Gemfile.lock ./
RUN bundle install --retry=3

# YARN
RUN npm install -g yarn
RUN yarn set version 3.2.1
COPY .yarnrc.yml ./
COPY package.json yarn.lock ./
RUN yarn install

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
RUN if [ "$RAILS_ENV" = "production" ] || [ "$RAILS_ENV" = "staging" ]; then \
  bundle exec rails assets:precompile ; \
  fi

# Kreas API dokumentadon ĉe /public/docs/api/v2/
RUN if [ "$RAILS_ENV" = "production" ]; then \
  npm install -g redoc-cli && \
  mkdir -p public/docs/api/v2/ && \
  redoc-cli build openapi/v2.yaml -o public/docs/api/v2/index.html ; \
  fi

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]

CMD bundle exec rails db:migrate; bundle exec rails server -b "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"
