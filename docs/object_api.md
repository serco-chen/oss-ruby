# Object API

Objects are the basic unit you can operation on OSS service. An object contains three parts: key, meta and data. Objects created through `put_object` cannot exceed 5GB, and the size of the object uploaded through 'multipart' cannot exceed 48.8TB.

* Object
  * Object name conventions
  * Upload an object through `put_object`
  * Create a 'folder' in a bucket
  * Set meta for an object
  * Append object
  * Multipart upload
  * List all objects in a bucket
  * Get object
  * Get only meta of an object
  * Delete object
  * Copy object

#### Object name conventions

* Encode in 'UTF-8'.
* Cannot start with "\" or "/".
* Cannot contain "\r" or "\n".
* Length between 1-1023 bytes.

#### Upload an object through `put_object`
You can upload a file in two ways.
```ruby
# method signature
put_object(bucket, object, body, headers = {})
```
```ruby
res = oss.put_object('bucket-name', 'object-name', 'string content')
p res.status # => 200
```
```ruby
# method signature
put_object_from_file(bucket, object, file_name, headers = {})
```
```ruby
res = oss.put_object_from_file('bucket-name', 'object-name', 'test.txt')
p res.status # => 200
```

#### Create a 'folder' in a bucket
OSS service does not support 'folder' by default, but you can achieve it by create a object with empty data and name like 'folder_name/'.

```ruby
res = oss.put_object('bucket-name', 'folder_name/', '')
p res.status # => 200
```

#### Set meta for an object
You can store meta information in an object through `put_object`
Meta headers must start with 'x-oss-meta-'.

```ruby
res = oss.put_object('bucket-name', 'object-name', 'string content', 'x-oss-meta-uploader' => 'Lucy')
p res.status # => 204
```
An object can have multiple meta headers, size limit of meta information is 2KB.

#### Append object
Only 'Appendable Object' can be appended through `append_object`. Object created by `append_object` is 'Appendable Object', object created by `put_object` is 'Normal Object'.

You must set the right position to append. You can read the file length of object, and you can also get the right append position throught information in  'x-oss-next-append-position' of the response headers.

```ruby
# method signature
append_object(bucket, object, body, position = 0, headers = {})
```

```ruby
res = oss.append_object('bucket-name', 'object-name', 'string-content', 0)
p res.status # => 200
p res.headers['x-oss-next-append-position'] # => 14
```

#### Multipart upload
See information in [Multipart Upload](docs/multipart_upload.md)

#### List all objects in a bucket
You can list all objects through `get_bucket`. Additional parameters like 'prefix', 'marker', 'delimiter', 'max-keys' and 'encoding-type' are supported.
```ruby
# method signature
get_bucket(name, params = {})
```
```ruby
res = oss.get_bucket('bucket-name')
p res.status # => 200

# use additional parameters
res = oss.get_bucket('bucket-name', 'MaxKeys' => 100)
p res.status # => 200
```

#### Get object
```ruby
# method signature
get_object(bucket, object, headers = {})
```
```ruby
res = oss.get_object('bucket-name', 'object-name')
p res.status # => 200
p res.body # => [344606 bytes of object data]
```

#### Get only meta of an object
Sometimes you only need the meta information of an object. This API reponds with meta information in headers and no body attached.

```ruby
# method signature
head_object(bucket, object, headers = {})
```

```ruby
res = oss.get_object('bucket-name', 'object-name')
p res.status # => 200
```

#### Delete object
```ruby
# method signature
delete_object(bucket, object)
```

```ruby
res = oss.delete_object('bucket-name', 'object-name')
p res.status # => 200
```

You can also delete multiple objects at once using `delete_multiple_objects`.

```ruby
# method signature
delete_multiple_objects(bucket, objects, quiet = false)
```

```ruby
res = oss.delete_multiple_objects('bucket-name', ['object1-name', 'object2-name'])
p res.status # => 200
```

#### Copy object
Copying object is supported. But you can only copy objects inside the same region.
```ruby
# method signature
copy_object(source_bucket, source_object, target_bucket, target_object, headers = {})
```

```ruby
res = oss.copy_object('source-bucket-name', 'source-object-name', 'target-bucket-name', 'target-object-name')
p res.status # => 200
```

And you can use this method simple modify the meta information of an object.
```ruby
res = oss.copy_object('target-bucket-name', 'target-object-name', 'target-bucket-name', 'target-object-name', "Content-Type" => "image/jpeg")
p res.status # => 200
```
