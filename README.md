# File uploader API

TODO: Document the principles and API

## Setup

An S3 bucket is required to store the uploaded files. This bucket
should have the minimum possible permissions; list objects, put object,
delete object.

`scripts/setup/` contains scripts and files to create an S3 bucket, an
IAM user, and apply the appropriate security policy.

The setup script has some pre-requisites, and requires some values (IAM
user and S3 bucket names) which are hard-coded as constants, so please
read `scripts/setup/README.md` before running any of the scripts.

## Run

```
cp .env.example .env
# ... and update the details in that file with the credentials created above
docker-compose build
docker-compose up
```
## Run outside docker

```bash
bundle exec rackup
```

## Testing

The File uploader is tested using RSpec, mutation testing and rubocop.
To test, run:

```bash
bundle install
bundle exec rake
```
