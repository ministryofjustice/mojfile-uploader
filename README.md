# File uploader

[![Build
Status](https://travis-ci.org/ministryofjustice/mojfile-uploader.svg?branch=master)](https://travis-ci.org/ministryofjustice/mojfile-uploader)

## Description

mojfile-uploader is designed as a drop-in component that can be added to any project
to facilitate users uploading files.

Any files that are uploaded are passed through ClamAV virus scanning, which runs on
a pair of bundled docker containers (one running the ClamAV daemon, and the other
exposing a REST interface to it).

Clean files are uploaded to an Azure Blob Storage container. Infected files are rejected.

The assumption here is that files are being uploaded by users, but that a separate
admin interface will be used to download the files. This means that, if the user's
credentials/session are compromised, an attacker would not be able to view the content
of any of the user's uploaded files. To this end;

* The uploader API does not expose any 'download' function
* The Azure Blob Storage container security settings should not permit the uploader to download any files

The uploader can list the uploaded files, and can delete any of them (so that the user
can correct mistakes).

At the root level of the container, the uploader creates _collections_, which are a group
of related files. You can add files to a collection explicitly by specifying its name,
or implicitly have it create a new collection by leaving out the name. Underneath
collections, the uploader optionally supports a single level of (sub)_folders_.

## API documentation

A [client gem](https://github.com/ministryofjustice/mojfile-uploader-api-client) has
been published that simplifies the interaction with the uploader API from Ruby apps.

### Adding files

Request. If no `collection_ref` route parameter is provided, a new collection will be created.

```ruby
POST to '/?:collection_ref?/new'
with a JSON payload
{folder: 'subfolder', file_filename: 'filename', file_data: 'Base64 encoded file data'}
```

Response:

```ruby
When success:
    200 status code
    JSON body: { collection: 'collection reference', folder: 'subfolder', key: 'filename' }

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
DELETE to '/:collection_ref/?:folder?/:filename'
```

Response:

```ruby
204 status code
```

### Listing files

Request:

```ruby
GET to '/:collection_ref/?:folder?'
```

Response:

```ruby
When success:
    200 status code
    JSON body: { collection: '12345', folder: 'subfolder', files: [{ key: '12345/subfolder/test.doc', title: 'test.doc', last_modified: '2016-12-05T12:20:02.000Z' }] }

When collection not found:
    404 status code
    JSON body: { errors: ["Collection '12345' does not exist or is empty."] }
```

## Setup

An Azure Blob Storage container is required to store the uploaded files. This container
should have the minimum possible permissions; list blobs, put blob,
delete blob.

## Note on Azure Storage Credentials

The `azure-storage-blob` gem will use the following ENV vars by default:

- AZURE_STORAGE_ACCOUNT
- AZURE_STORAGE_ACCESS_KEY

## Run Locally

Create the .env file

```
cp .env.example .env
```

Update the details in that file.

You can create a new Azure storage in the Azure Portal [stgttfilestore account](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/tt_stg_taxtribunalsazure_resource_group/providers/Microsoft.Storage/storageAccounts/stgttfilestore/containersList)

Then in any account you want to use to access MOJFile-Uploader using MOJFile-Uploader-API-Client, please update:
AZURE_STORAGE_ACCOUNT
AZURE_STORAGE_ACCESS_KEY
CONTAINER_NAME

**With docker - no longer supported**

```
docker-compose build
docker-compose up
```
The above commands will create and run the uploader and the AV scanner containers.

**Without docker**

Run:

```
DO_NOT_SCAN=true dotenv rackup
```

If you do not want to skip virus scanning, The AV scanner must be running before you start the uploader. Then run:

```
dotenv rackup
```


## Scanner endpoint

If the virus scanner is not available from this application at
`http://clamav-rest:8080/scan` then you will need to set the
`SCANNER_URL` environment variable to point at the correct endpoint.  It
*should* be available if the app is launched using docker compose.

## Testing

The File uploader is tested using RSpec, mutation testing and rubocop.
To test, run:

```bash
bundle install
bundle exec rake
```

## File uploader example app

Included in the directory `example_app` there is a simple Sinatra app to show how to integrate
the File Uploader JQuery plugin with the client gem.

### Running the app

First make sure in file `example_app/config.ru` the HttpClient base_url points to the right URL/port
where the MOJ Uploader app is running.

In the `example_app` directory, run:

```sh
bundle
bundle exec puma -p 3003  # or any other port you want
```

Go to `http://localhost:3003` to see the uploader example.
