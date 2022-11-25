FROM gitpod/workspace-full:2022-09-11-15-11-40

RUN sudo apt-get update \
  && sudo apt-get install -y \
    apt-utils \
    curl \
    git \
    postgresql-client \
    vim \
    telnet

USER gitpod

# Install Ruby version 2.7.6 and set it as default
RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc
RUN bash -lc "rvm install ruby-2.7.6 && rvm use ruby-2.7.6 --default"
RUN echo "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc

# Install Solargraph
RUN bash -lc "gem install solargraph"

# Install NodeJS 14 and set it as default
RUN bash -c 'VERSION="lts/fermium" \
  && source $HOME/.nvm/nvm.sh && nvm install $VERSION \
  && nvm use $VERSION && nvm alias default $VERSION'
RUN echo "nvm use default &>/dev/null" >> ~/.bashrc.d/51-nvm-fix
RUN bash -c "npm install -g npm@latest"
