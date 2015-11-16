# oss-ruby

`oss-ruby` is the Ruby SDK of Aliyun OSS API service. All oss api methods are available through this SDK.

What is [Aliyun OSS](http://www.aliyun.com/product/oss)  
Aliyun OSS [API Official Doc](https://docs.aliyun.com/#/pub/oss)

**Note**
It's released on [RubyGems](https://rubygems.org/gems/oss-ruby).
If something doesn't work, feel free to report a bug or start an issue.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oss-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oss-ruby

If you prefer to use the latest code, you can build from source:

```
gem build oss-ruby.gemspec
gem install oss-ruby-<VERSION>.gem
```

## Usage

#### Initialization
`oss-ruby` requires you to initialize an instance before usage.

```ruby
# Initialize oss-ruby
require 'oss'

oss = OSS.new({
  endpoint: 'oss-cn-hangzhou.aliyuncs.com',
  access_key_id: 'your_access_key',
  access_key_secret: 'your_access_secret'
})
```

#### Call API with SDK
Using sdk to call oss service is quite straight forward.

```ruby
# Get Service
res = oss.get_service
p res.status # => 200
```

#### API Response

Some of the APIs returns with a xml string as response body.
`oss-ruby` uses `Nokogiri` to parse the xml document internally.

```ruby
res = oss.get_service
p res.status # => 200
p res.body # => "<?xml version=\"1.0\"..."
p res.doc.xpath("//ID").text # => "1216909307023357"
# and it can be shorter
p res.xpath("//ID").text # => "1216909307023357"
```

When API responds with an error. `oss-ruby` provide a `error` method in response object to easily parse error messages.

```ruby
res = oss.get_bucket('non-exist-bucket')
p res.status # => 404
p res.body # => "<?xml version=\"1.0\"..."
p res.error.code #=> "NoSuchBucket"
p res.error.message #=> "The specified bucket does not exist."
```

And if network connection fails, `oss-ruby` will raise a `OSS::HTTPClientError` with backtrace and error message.

## Other Documentation

* [Quick Start](docs/quick_start.md)
* [Bucket API](docs/bucket_api.md)
* [Object API](docs/object_api.md)
* [Multipart Upload](docs/multipart_upload.md)
* [Cross-Origin Resource Sharing](docs/cors.md)
