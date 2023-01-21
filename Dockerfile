FROM ruby:3.1.2
RUN apt-get update && apt-get install -y nodejs
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . ./
EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]

# Attempt to run trufflerruby 22.3.0 but it was too slow!
#FROM ubuntu
#SHELL ["/bin/bash", "-c"]
#RUN apt-get update -y
#
## Install & configure timezone
#ENV TZ="Etc/UTC"
#RUN apt-get install -y tzdata
#
## Install locales
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#RUN apt-get install -y locales
#RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
#
## Install rvm dependencies
#RUN apt-get install -y curl
#RUN curl -sSL https://get.rvm.io | bash
#RUN echo "source /etc/profile.d/rvm.sh" | tee -a ~/.bashrc ~/.profile ~/.bash_profile
#
## Customizations
#ENV RUBY_VERSION="truffleruby-22.3.0"
#
#RUN source /etc/profile.d/rvm.sh && rvm install ${RUBY_VERSION} && \
#    rvm --default use ${RUBY_VERSION}
#RUN source /etc/profile.d/rvm.sh && gem install bundler --version '2.3.7'
#
## Set application directory
#WORKDIR /app
#
## Gems dependencies
#RUN apt-get install -y libpq-dev xz-utils
#COPY Gemfile* .ruby-version ./
#RUN source /etc/profile.d/rvm.sh && rvm ${RUBY_VERSION} do bundle install
#
#COPY . ./
#EXPOSE 3000
#ENTRYPOINT ["./docker-entrypoint.sh"]
#
## Installing from graalvm repo coudn't install nokogi gem for some reason
##FROM ghcr.io/graalvm/truffleruby:22.3
##RUN yum install -y postgresql-devel xz libxml2 zlib-devel libxslt
##RUN gem install bundler --version '2.3.7'
##COPY Gemfile* .
##RUN bundle install