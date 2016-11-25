#!/usr/bin/env bash

# Use this script to test a service that is already running (e.g. by invoking "docker-compose up")
# The script should be invoked from the root directory of the project, i.e. ./test/test.sh

set -euo pipefail

REST_INTERFACE_PORT=8080

source ./helper.sh

function main() {
  test_rest_interface_container
}

function test_rest_interface_container() {
  test_rest_interface_ping
  test_scan_clean_file
  test_scan_infected_file
}

function test_rest_interface_ping() {
  echo_yellow "TEST ping the REST interface"

  local response=$(ping_rest_interface)

  if [ ${response} == "200" ]; then
    echo_green "SUCCESS: REST interface responding"
  else
    echo_red "FAILED rest api not starting"
    exit 1
  fi
}

function ping_rest_interface() {
  echo $(curl -w %{http_code} -s --output /dev/null localhost:${REST_INTERFACE_PORT})
}

function test_scan_clean_file() {
  local readonly virus_test=$(curl -s -F "name=test-clean" -F "file=@helper.sh" localhost:${REST_INTERFACE_PORT}/scan | grep -o true)

  echo_yellow "TEST scanning a clean file"

  local readonly foo=$(curl -s -F "name=test-clean" -F "file=@@helper.sh" localhost:${REST_INTERFACE_PORT}/scan)
  echo "-------------------------"
  echo ${foo}
  echo "-------------------------"

  if [ ${virus_test} == "true" ]; then
    echo_green "SUCCESS rest api working and scanning clean files Correctly"
  else
    echo_red "FAILED rest api not scanning clean files correctly"
    exit 1
  fi
}

function test_scan_infected_file() {
  local readonly virus_test=$(curl -s -F "name=test-virus" -F "file=@test/eicar.com" localhost:${REST_INTERFACE_PORT}/scan | grep -o false)
  local readonly foo=$(curl -s -F "name=test-virus" -F "file=@test/eicar.com" localhost:${REST_INTERFACE_PORT}/scan)
  echo "-------------------------"
  echo ${foo}
  echo "-------------------------"

  echo_yellow "TEST scanning an infected file"

  if [ ${virus_test} == "false" ]; then
    echo_green "SUCCESS rest api working and detecting viruses Correctly"
    exit 0
  else
    echo_red "FAILED rest api not detecting viruses correctly"
    exit 1
  fi
}

main
