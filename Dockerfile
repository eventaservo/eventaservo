ARG IMAGE=2.7.6-alpine3.14

FROM ruby:${IMAGE} as build

WORKDIR /eventaservo

RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache \
      alpine-sdk \
      shared-mime-info \
      imagemagick6-dev \
      postgresql-dev \
      nodejs \
      npm \
      yarn \
      sqlite-dev \
      tzdata \
  && rm -rf /var/cache/apk/*

# Instala o Bundler e as Gems
RUN gem install bundler:2.1.4
RUN bundle config set without development test
RUN bundle config set deployment true
RUN bundle config set frozen true
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=3 --retry=3

# YARN
RUN npm install -g yarn
RUN yarn set version 3.2.1
COPY .yarnrc.yml ./
COPY package.json yarn.lock ./
RUN yarn install

# Kreas API dokumentadon ĉe /public/docs/api/v2/
RUN npm i -g redoc-cli
RUN mkdir -p public/docs/api/v2/
COPY openapi/v2.yaml ./openapi/
RUN redoc-cli build openapi/v2.yaml -o public/docs/api/v2/index.html

COPY . .

# Sets ambient variables
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
ENV IPINFO_KEY=${IPINFO_KEY}

ARG AMBIENTE=production
ENV RAILS_ENV=${AMBIENTE}

RUN bundle exec rails assets:precompile

# Delete unecessary files from image
RUN rm -rf node_modules \
  && rm -rf tmp/* \
  && rm -rf vendor/bundle/ruby/${RUBY_MAJOR}.0/cache/* \
  && find vendor/bundle/ruby/${RUBY_MAJOR}.0/gems/ -name "*.c" -delete \
  && find vendor/bundle/ruby/${RUBY_MAJOR}.0/gems/ -name "*.o" -delete

###

FROM ruby:${IMAGE}

RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache \
      alpine-sdk \
      shared-mime-info \
      imagemagick \
      imagemagick6-dev \
      postgresql-dev \
      poppler-utils \
      tzdata \
  && rm -rf /var/cache/apk/*

WORKDIR /eventaservo

RUN bundle config set without development test
RUN bundle config set deployment true
RUN bundle config set frozen true
RUN bundle config path vendor/bundle

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

ARG AMBIENTE=production
ENV RAILS_ENV=${AMBIENTE}

COPY --from=build /eventaservo /eventaservo

EXPOSE 3000

CMD bundle exec rails db:migrate; bundle exec rails server -b "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"
