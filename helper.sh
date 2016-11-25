#!/usr/bin/env bash

# Coloured output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NOCOLOUR='\033[0m'

function echo_red() {
  local readonly message=$1
  echo_colour ${RED} "${message}"
}

function echo_green() {
  local readonly message=$1
  echo_colour ${GREEN} "${message}"
}

function echo_yellow() {
  local readonly message=$1
  echo_colour ${YELLOW} "${message}"
}

function echo_colour() {
  local readonly colour=$1
  local readonly message=$2
  echo -e "${colour}${message}${NOCOLOUR}"
}

function execute_silently() {
  local readonly cmd=$1
  ${cmd} >/dev/null 2>&1 || true
}

function wait_until_cmd() {
  cmd="$@"
  max_retries=20
  wait_time=${WAIT_TIME:-5}
  retries=0
  while true ; do
    if ! bash -c "${cmd}" &> /dev/null ; then
      retries=$((retries + 1))
      echo "Testing for readyness..."
      if [ ${retries} -eq ${max_retries} ]; then
        return 1
      else
        echo "Retrying, $retries out of $max_retries..."
        sleep ${wait_time}
      fi
    else

      return 0
    fi
  done
  echo
  return 1
}
