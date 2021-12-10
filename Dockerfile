ARG IMAGE=2.7.5-alpine3.14
ARG AMBIENTE=production

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
RUN bundle install --jobs=1 --retry=1

# YARN
COPY package.json yarn.lock ./
RUN yarn install

# Define as variaveis de ambiente
ENV RAILS_ENV=${AMBIENTE}
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
ENV IPINFO_KEY=${IPINFO_KEY}

COPY . .

RUN bundle exec rails assets:precompile

# Apaga todos os arquivos desnecessários

RUN rm -rf node_modules \
  && rm -rf tmp/* \
  && rm -rf vendor/bundle/ruby/${RUBY_MAJOR}.0/cache/* \
  && find vendor/bundle/ruby/${RUBY_MAJOR}.0/gems/ -name "*.c" -delete \
  && find vendor/bundle/ruby/${RUBY_MAJOR}.0/gems/ -name "*.o" -delete 

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

ENV RAILS_ENV=${AMBIENTE}
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

RUN bundle config set without development test
RUN bundle config set deployment true
RUN bundle config set frozen true
RUN bundle config path vendor/bundle

COPY --from=build /eventaservo /eventaservo

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"]
