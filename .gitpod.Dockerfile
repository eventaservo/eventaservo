FROM gitpod/workspace-base

RUN sudo apt-get update
RUN sudo apt-get install -y \
  apt-utils \
  curl \
  git \
  vim \
  telnet

WORKDIR /workspace/eventaservo

# ASDF
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
RUN echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
ENV PATH="${PATH}:/home/gitpod/.asdf/shims:/home/gitpod/.asdf/bin"
RUN bash -c "asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
RUN asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
COPY .tool-versions .
RUN asdf install

# Gems
RUN gem install \
  foreman \
  rubocop \
  rubocop-rails
