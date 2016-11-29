# File uploader API

TODO: Document the API

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
