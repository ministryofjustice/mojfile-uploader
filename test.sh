#!/bin/bash

# Script to test the file uploader application. Replace the URL with wherever the
# uploader application should be, from your point of view

# Listing files:
#
# You can test this using curl;
#
#   $ curl 'http://localhost:9292/12345'
#
# This should respond with;
#
#  {"errors":["Collection '12345' does not exist or is empty."]}
#


# Uploading a file

data="{\"file_title\":\"Test Upload\",\"file_filename\":\"testfile.docx\",\"file_data\":\"RW5jb2RlZCBkb2N1bWVudCBib2R5\\n\"}"

curl -X POST \
  -H "Content-Type: application/json" \
  -d "${data}" \
  http://localhost:9292/new

# This should respond with something like this;
#
#  {"collection":"e921ca09-cb64-40d2-b414-1bc80ca709c6","key":"be6f311b-1f03-4a24-b624-58c2b0765cd1.Test Upload.docx"}
#
# You should then be able to list the files like this;
#
#   $ curl 'http://localhost:9292/e921ca09-cb64-40d2-b414-1bc80ca709c6'
#
# ...and see the uploaded file in the list
#
#  {"collection":"e921ca09-cb64-40d2-b414-1bc80ca709c6","files":[{"key":"e921ca09-cb64-40d2-b414-1bc80ca709c6/testfile.docx","title":"testfile.docx","last_modified":"2016-11-23 12:16:37 UTC"}]}
#

# Trying to upload a virus-infected file

# This is the base64 encoded data from eicar.txt - the virus scanning test pattern (ClamAV will recognise this as infected, but it's not)
# X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*
eicar_base64="WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFO\nVElWSVJVUy1URVNULUZJTEUhJEgrSCo=\n"
data="{\"file_title\":\"Infected Upload\",\"file_filename\":\"testfile2.docx\",\"file_data\":\"${eicar_base64}\\n\"}"

curl -X POST \
  -H "Content-Type: application/json" \
  -d "${data}" \
  http://localhost:9292/new

# This should respond with;
#
#  {"errors":["Virus scan failed"]}
#

