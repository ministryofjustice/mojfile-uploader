FROM phusion/passenger-ruby27

# Adding argument support for ping.json
ARG APP_VERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APP_VERSION ${APP_VERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

# fix to address http://tzinfo.github.io/datasourcenotfound - PET ONLY
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get install shared-mime-info -qy tzdata --no-install-recommends && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

RUN bash -lc 'rvm get stable; rvm install 2.7.3; rvm --default use ruby-2.7.3'

COPY . /home/app
WORKDIR /home/app

RUN gem install bundler -v 2.2.15
RUN bundle install --without test development

ENV PUMA_PORT 8000
EXPOSE $PUMA_PORT

# running app as a servive
ENV PHUSION true
COPY run.sh /home/app/run
RUN chmod +x /home/app/run

CMD ["./run"]