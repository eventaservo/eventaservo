FROM ruby:3.0-alpine3.16

WORKDIR /app

RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache \
  alpine-sdk \
  bash \
  imagemagick \
  imagemagick6-dev \
  nodejs \
  npm \
  postgresql-dev \
  shared-mime-info \
  sqlite-dev \
  tzdata \
  vim \
  vips \
  yarn \
  && rm -rf /var/cache/apk/*

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

# Setup cron jobs
RUN bundle exec whenever --update-crontab --set environment=$RAILS_ENV

# Kreas API dokumentadon ĉe /public/docs/api/v2/
RUN if [ "$RAILS_ENV" = "production" ]; then \
  npm install -g redoc-cli && \
  mkdir -p public/docs/api/v2/ && \
  redoc-cli build openapi/v2.yaml -o public/docs/api/v2/index.html ; \
  fi

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]

CMD bundle exec rails db:migrate; bundle exec rails server -b "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"
