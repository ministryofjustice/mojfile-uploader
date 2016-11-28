#!/bin/bash

# Script to test the file uploader application. Replace the URL with wherever the
# uploader application should be, from your point of view

UPLOADER_URL=http://localhost:9292
COLLECTION_REF=12345

main() {
  echo "List files..................."
  list_files
  echo
  echo

  echo "Clean file..................."
  upload_clean_file
  echo
  echo

  echo "Infected file................"
  upload_infected_file
  echo
}

# This should respond with;
#  {"errors":["Collection '12345' does not exist or is empty."]}
# ...or a list of the files in the collection
list_files() {
  curl ${UPLOADER_URL}/${COLLECTION_REF}
}

upload_clean_file() {
  data="{\"file_title\":\"Test Upload\",\"file_filename\":\"testfile.docx\",\"file_data\":\"RW5jb2RlZCBkb2N1bWVudCBib2R5\\n\"}"

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "${data}" \
    ${UPLOADER_URL}/new
}

function upload_infected_file() {
  # This is the eicar virus scanning test pattern (ClamAV will recognise this as infected, but it's not)
  # NB: 4\\ should be 4\ but something is escaping this when we pass it through sinatra/ruby/something
  eicar='X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
  data="{\"file_title\":\"Infected Upload\",\"file_filename\":\"testfile2.docx\",\"file_data\":\"${eicar}\n\"}"

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "${data}" \
    ${UPLOADER_URL}/new

  # This should respond with;
  #
  #  {"errors":["Virus scan failed"]}
  #
}

main
