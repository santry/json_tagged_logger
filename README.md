# JsonTaggedLogger

[![Build Status](https://github.com/santry/json_tagged_logger/actions/workflows/ci.yml/badge.svg)](https://github.com/santry/json_tagged_logger/actions/workflows/ci.yml)

`JsonTaggedLogger` works in conjunction with [`ActiveSupport::TaggedLogging`](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html) and (optionally) [Lograge](https://github.com/roidrage/lograge) to produce JSON-formatted log output. By itself, `ActiveSupport::TaggedLogging` supports simple tagging. With `JsonTaggedLogger`, you can compose key/value pairs, simple tags, and the log message itself into a single JSON document for easy consumption and parsing in log aggregators.

## Usage

Given the following configuration,

```ruby
# Gemfile
gem 'json_tagged_logger'
gem 'lograge' # since you probably want all your request logs in JSON

# config/environments/production.rb
Rails.application.configure do
  # …
  config.log_tags = JsonTaggedLogger::LogTagsConfig.generate(
    :request_id,
    :host,
    ->(request) { { my_param: request.query_parameters["my_param"] }.to_json },
    JsonTaggedLogger::TagFromSession.get(:user_id),
    JsonTaggedLogger::TagFromHeaders.get(my_custom_header: "X-Custom-Header"),
  )

  logger = ActiveSupport::Logger.new(STDOUT)
  config.logger = JsonTaggedLogger::Logger.new(logger)

  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  # …
end
```

A request like

```
curl -H "X-Custom-Header: some header value" 'http://127.0.0.1:3000/?my_param=param%20value'
```

will get you something like

```json
{
  "level": "INFO",
  "request_id": "914f6104-538d-4ddc-beef-37bfe06ca1c7",
  "host": "127.0.0.1",
  "my_param": "param value",
  "user_id": "99",
  "my_custom_header": "some header value",
  "method": "GET",
  "path": "/",
  "format": "*/*",
  "controller": "SessionsController",
  "action": "new",
  "status": 302,
  "duration": 0.51,
  "view": 0,
  "db": 0,
  "location": "http://127.0.0.1:3000/profile"
}
```

[_Note_: By default, `JsonTaggedLogger::Formatter` outputs logs as single lines without extra whitespace. Setting `JsonTaggedLogger::Formatter#pretty_print` to `true` will pretty print the logs, as I've done in these examples.]

Importantly, if the controller action (or any code it calls along the way) has an explicit call to `Rails.logger.tagged("TAG").info("tagged log message")`, you'll get the same key/value tags (`request_id`, `host`, `my_param`, &c.) in the JSON document along with a `tags` key:

```json
{
  "level": "INFO",
  "request_id": "914f6104-538d-4ddc-beef-37bfe06ca1c7",
  "host": "127.0.0.1",
  "my_param": "param value",
  "user_id": "99",
  "my_custom_header": "some header value",
  "tags": [
    "TAG"
  ],
  "msg": "tagged log message"
}
```

If you have nested calls to the tagged logger, like

```ruby
Rails.logger.tagged("TAG") do
  Rails.logger.tagged("NESTED").info("nested tagged log message")
end

```

those will be added to the `tags` key in the JSON document

```json
{
  "level": "INFO",
  "request_id": "914f6104-538d-4ddc-beef-37bfe06ca1c7",
  "host": "127.0.0.1",
  "my_param": "param value",
  "user_id": "99",
  "my_custom_header": "some header value",
  "tags": [
    "TAG",
    "NESTED"
  ],
  "msg": "nested tagged log message"
}
```

## Why?

On its own, `ActiveSupport::TaggedLogging` adds individual tags wrapped in square brackets at the start of each line of log output. A configuration like

```ruby
Rails.application.configure do
  # …
  config.log_tags = [ :request_id, :host, ->(request) { request.query_parameters["my_param"] } ]
  logger = ActiveSupport::Logger.new(STDOUT)
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  # …
end
```

will get you logs like

```
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value] Started GET "/?my_param=param%20value" for 127.0.0.1 at 2023-01-15 00:13:21 -0500
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value] Processing by SessionsController#new as */*
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value]   Parameters: {"my_param"=>"param value"}
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value] [TAG] [NESTED] nested tagged log message
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value] Redirected to http://127.0.0.1:3000/sign_in
[22a03298-5fd9-4b28-bbe2-1d4c0d7f74f0] [127.0.0.1] [param value] Completed 302 Found in 1ms (ActiveRecord: 0.0ms | Allocations: 1070)
```

This is fine as far as it goes, but if you use tagged logging with something like [Lograge](https://github.com/roidrage/lograge) to format your request logs as JSON, the list of square-bracketed tags will still just be prepended to the log line, followed by the JSON. Also, any calls to `Rails.logger.tagged` will be logged as plain text:

```
[d4fac896-f916-48d7-9d32-d35a39cfb7d8] [127.0.0.1] [param value] [TAG] [NESTED] nested tagged log message
[d4fac896-f916-48d7-9d32-d35a39cfb7d8] [127.0.0.1] [param value] {"method":"GET","path":"/","format":"*/*","controller":"SessionsController","action":"new","status":302,"duration":1.2,"view":0.0,"db":0.0,"location":"http://127.0.0.1:3000/sign_in"}
```
