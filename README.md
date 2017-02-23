# File uploader

## Description

mojfile-uploader is designed as a drop-in component that can be added to any project
to facilitate users uploading files.

Any files that are uploaded are passed through ClamAV virus scanning, which runs on
a pair of bundled docker containers (one running the ClamAV daemon, and the other
exposing a REST interface to it).

Clean files are uploaded to an S3 bucket. Infected files are rejected.

The assumption here is that files are being uploaded by users, but that a separate
admin interface will be used to download the files. This means that, if the user's
credentials/session are compromised, an attacker would not be able to view the content
of any of the user's uploaded files. To this end;

* The uploader API does not expose any 'download' function
* The S3 bucket security settings should not permit the uploader to download any files

The uploader can list the uploaded files, and can delete any of them (so that the user
can correct mistakes).

## API documentation

A [client gem](https://github.com/ministryofjustice/mojfile-uploader-api-client) has been published that simplifies the interaction with the uploader API.

### Adding files

Request. If no collection_ref route parameter is provided, a new collection will be created.

```ruby
POST to '/?:collection_ref?/new'
with a JSON payload
{file_filename: 'filename', file_data: 'Base64 encoded file data'}
```

Response:

```ruby
When success:
    200 status code
    JSON body: { collection: 'collection reference', key: 'filename' }
  
When virus detected:
    400 status code
    JSON body: { errors: ['Virus scan failed'] }
  
When failure:
    422 status code
    JSON body: { errors: ['file_filename must be provided', 'file_data must be provided'] }
```

### Deleting files

Request:

```ruby
DELETE to '/:collection_ref/:filename'
```

Response:

```ruby
204 status code
```

### Listing files

Request:

```ruby
GET to '/:collection_ref'
```

Response:

```ruby
When success:
    200 status code
    JSON body: { collection: '12345', files: [{ key: '12345/test.doc', last_modified: '2016-12-05T12:20:02.000Z' }] }
  
When collection not found:
    404 status code
    JSON body: { errors: ["Collection '12345' does not exist or is empty."] }
```

## Setup

An S3 bucket is required to store the uploaded files. This bucket
should have the minimum possible permissions; list objects, put object,
delete object.

The scripts for easy automation of these tasks can be found in the
[Mojfile S3 bucket setup repo](https://github.com/ministryofjustice/mojfile-s3-bucket-setup)
However, those scripts assume that an IAM *user* will authenticate to the S3 bucket.
In production, IAM *roles* will be used, such that the container in which the application
is running is granted (or not) appropriate permissions to operate on the S3 bucket.

## Note on AWS Credentials

These are no longer needed in production as we now use roles.  They are
still required if you want to run the application locally.  They are
picked up automatically by `aws-sdk` if you use the environment
variables set in `env.example`.

## Run Locally

```
cp .env.example .env
# update the details in that file with the credentials created above
# remove the `export` commands
docker-compose build
docker-compose up
```

It does not need the `.env` file in the production container.

## Scanner endpoint

If the virus scanner is not available from this application at
`http://clamav-rest:8080/scan` then you will need to set the
`SCANNER_URL` environment variable to point at the correct endpoint.  It
*should* be available if the app is launched using docker compose.

## Run outside docker

```bash
cp .env.example .env
# ... and update the details in that file with the credentials created above
bundle exec rackup
```

## Testing

The File uploader is tested using RSpec, mutation testing and rubocop.
To test, run:

```bash
bundle install
bundle exec rake
```

## File uploader example app

Included in the directory `example_app` there is a simple Sinatra app to show how to integrate the File Uploader JQuery plugin with the client gem.

### Running the app

First make sure in file `example_app/config.ru` the HttpClient base_url points to the right URL/port where the MOJ Uploader app is running.

In the `example_app` directory, run:

```sh
bundle
bundle exec puma -p 3003  # or any other port you want
```

Go to `http://localhost:3003` to see the uploader example.
