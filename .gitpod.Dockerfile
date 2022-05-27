# Docker-compose file for DEVELOPMENT containers in GITPOD.io

FROM gitpod/workspace-base

WORKDIR /eventaservo

RUN sudo apt-get update
RUN sudo apt-get upgrade -y
RUN sudo apt-get install -y \
  apt-utils \
  telnet \
  iputils-ping \
  vim \
  zsh

# Node 14
# RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
# RUN apt-get install -y nodejs

# RUN npm i -g yarn

# RUN apt-get install -y \
  

# Bundler and gems
# RUN gem install sassc:2.4.0
# RUN gem install bundler:2.1.4

# COPY Gemfile Gemfile.lock /eventaservo/
# RUN bundle install --jobs=3 --retry=3

# YARN
# COPY package.json yarn.lock ./
# RUN yarn install

# RUN apt-get install -y 

EXPOSE 3000
# CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"]
