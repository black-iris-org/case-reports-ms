ARG BASE_TAG=base
FROM trekmedics/case-reports-ms:${BASE_TAG}
SHELL ["/bin/bash", "-c"]


# Install locales and set UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY Gemfile* ./
RUN BUNDLER_VERSION=$(sed -n '/BUNDLED WITH/{n;p;}' Gemfile.lock | awk '{print $1}') \
    gem install bundler ${BUNDLER_VERSION}

RUN mkdir -p vendor
ADD vendor/bundle ./vendor/bundle
RUN bundle config set --local path '/app/vendor/bundle'
RUN bundle install
ADD . ./
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