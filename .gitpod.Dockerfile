FROM gitpod/workspace-full

RUN sudo apt-get update \
  && sudo apt-get install -y \
    apt-utils \
    curl \
    git \
    vim \
    telnet

USER gitpod

WORKDIR /workspace/eventaservo

# Install Ruby version 2.7.6 and set it as default
RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc
RUN bash -lc "rvm install ruby-2.7.6 && rvm use ruby-2.7.6 --default"
RUN echo "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc
RUN echo "gem: --no-document" >> ~/.gemrc

# Install some basic gems
RUN bash -lc "gem install \
  bundler:2.3.19 \
  foreman \
  rubocop \
  rubocop-rails \
  reek \
  solargraph \
  sassc"

# Install NodeJS 14 and set it as default
RUN bash -c 'VERSION="lts/fermium" \
  && source $HOME/.nvm/nvm.sh && nvm install $VERSION \
  && nvm use $VERSION && nvm alias default $VERSION'
RUN echo "nvm use default &>/dev/null" >> ~/.bashrc.d/51-nvm-fix
