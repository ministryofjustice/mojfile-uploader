#!/bin/bash

PHUSION_SERVICE="${PHUSION:-false}"
case ${PHUSION_SERVICE} in
true)
    echo "running as service"
    cd /home/app/
    bundle exec puma -p $PUMA_PORT
    ;;
*)
    echo "normal startup"
    bundle exec puma -p $PUMA_PORT
    ;;
esac
