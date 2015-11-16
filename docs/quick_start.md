# Quick Start

This doc will show you basic operations of OSS APIs.

* Step 1: Initialize the `oss-ruby` SDK
* Step 2: Create a new bucket
* Step 3: Upload a file to a bucket
* Step 4: List all the objects of a bucket
* Step 5: Retrieve object from a bucket

#### Step 1: Initialization
`oss-ruby` requires you to initialize an instance before usage.

```ruby
require 'oss'

oss = OSS.new({
  endpoint: 'oss-cn-hangzhou.aliyuncs.com',
  access_key_id: 'your_access_key',
  access_key_secret: 'your_access_secret'
})
```

#### Step 2: Create a new bucket
Bucket is the objects container of the OSS service. The bucket name must be unique.

```ruby
res = oss.put_bucket 'bucket-name'
p res.status # => 200
```

#### Step 3: Upload a file to a bucket
Object is the basic unit in OSS storage service. You can store a file in a bucket as one object.

```ruby
res = oss.put_object_from_file('bucket-name', 'object-name', 'local-file.txt')
p res.status # => 200
```

#### Step 4: List all the objects of a bucket
You can view all objects in a bucket through this API.

```ruby
res = oss.get_bucket('bucket-name')
p res.status # => 200
```

#### Step 5: Retrieve object from a bucket
Retrieve object from a bucket is pretty easy.

```ruby
res = oss.get_object('bucket-name', 'object-name')
p res.status # => 200
p res.body # => [344606 bytes of object data]
```

And you can get meta information of the object from the response headers.
