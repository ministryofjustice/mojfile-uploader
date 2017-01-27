FROM ministryofjustice/ruby:2.3.1-webapp-onbuild

ENV PUMA_PORT 9292
ENV RACK_ENV production

ENV BUCKET_NAME replace_this_at_build_time
ENV SCANNER_URL replace_this_at_build_time
ENV SENTRY_DSN  replace_this_at_build_time

RUN touch /etc/inittab

RUN rm /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y

EXPOSE $PUMA_PORT

ENTRYPOINT ["./run.sh"]
