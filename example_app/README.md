# File uploader example app

This example Sinatra app will show how to integrate the File Uploader JQuery plugin with the client gem.

## Running the app

First make sure in file `config.ru` the HttpClient base_url points to the right URL where the MOJ Uploader app is running.

In the `example_app` directory, run:

```sh
bundle
bundle exec puma -p 3003  # or any other port you want
```

Go to `http://localhost:3003` to see the uploader example.
