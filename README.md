# Carrierwave::Attachmentscanner

[![Build Status](https://travis-ci.org/attachmentscanner/carrierwave-attachmentscanner.svg?branch=master)](https://travis-ci.org/attachmentscanner/carrierwave-attachmentscanner)

Carrierwave::Attachmentscanner allows you to scan any file uploaded by
[CarrierWave](https://github.com/carrierwaveuploader/carrierwave) for viruses or
other malicious content.

It works by sending the upload to [Attachment Scanner](http://www.attachmentscanner.com)
to be checked and then raising an error if the file matches a known database.

## Installation

Add `carrierwave-attachmentscanner` to your `Gemfile`

```ruby
gem 'carrierwave-attachmentscanner'
```

Download and install by running:

```bash
bundle
```

Initialize the scanner with your `cluster_url` and `api_token`
(If you don't already have these values head to
[Attachment Scanner](http://www.attachmentscanner.com) and sign up for an account):

### Adding to an Uploader

You can then include `CarrierWave::AttachmentScanner` in your uploaders:

```ruby
class YourUploader < CarrierWave::Uploader::Base
  include CarrierWave::AttachmentScanner
end
```

### Adding your credentials

```bash
bundle exec rails generate carrierwave_attachmentscanner:config [CLUSTER_URL] [API_TOKEN]
```

This will create `config/initializers/carrierwave_attachmentscanner.rb` with the
following content:

```ruby
CarrierWave::AttachmentScanner.configure do |config|
  config.url = "CLUSTER_URL"
  config.api_token = "API_TOKEN"
end
```

If you leave things blank we'll assume that you're going to set the config values
within ENV variables like the following:

```ruby
CarrierWave::AttachmentScanner.configure do |config|
  config.url = ENV['ATTACHMENT_SCANNER_URL']
  config.api_token = ENV['ATTACHMENT_SCANNER_API_TOKEN']
end
```

# Usage

Once installed `CarrierWave::AttachmentScanner` will call the endpoint with any
file a user attempts to call on your uploader.

It will raise a `CarrierWave::IntegrityError` whenever a malicious file is found,
by default this will then prevent the model from saving.

## Customising the response

There are two methods that can be used to compare the response from the
AttachmentScanner API and present an error message within CarrierWave.

The first method `blocked_scan_statuses` is used to compare the scan result with
a list of statuses.

```ruby
def blocked_scan_statuses
  %w(found)
end
```

The second can be overridden in order to use the response to alter the upload
message.

```ruby
# This can be overridden in order to change the message
def scan_error_message(result)
  "AttachmentScanner prevented this upload"
end
```

Finally if you need total control you can override the `scan_result_allowed?`
method completely.

# Development / Contributing

Pull requests are welcome. There is an RSpec suite at `/spec`. Please ensure that
tests pass before submitting a pull request.

Thank you for making `CarrierWave::AttachmentScanner` better.
