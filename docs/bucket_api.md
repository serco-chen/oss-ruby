# Bucket API

Buckets are the instances with full control of permissions and logs, and they are also the pricing unit in OSS service. Objects must belong to one particular bucket. User can create 10 buckets at most, and space limit of a bucket is 2PB.

* Bucket
  * Bucket name conventions
  * Create a bucket
  * List all buckets
  * Delete a bucket
  * Get location of a bucket
  * Manage permissions of a bucket

#### Bucket name conventions

* Contains only alphanumeric characters, numbers and hyphen.
* Only lower case is allowed.
* Must start with alphanumeric character or number.
* Length between 3-63 bytes.

#### Create a bucket
You can setup the permission of the bucket during creation, default permission is `private`. And you can also choose which [location](https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region) to store the bucket.

**Note: bucket once created cannot change its name later.**

```ruby
# method signature
put_bucket(name, permission = 'private', location = 'oss-cn-hangzhou')
```
```ruby
res = oss.put_bucket('bucket-name')
p res.status # => 200
```

#### List all buckets
You can get the buckets information by simple calling this method without arguments. And 'prefix', 'marker' and 'max-keys' are possible keys to filter results.
```ruby
# method signature
get_service(params = {})
```

```ruby
res = oss.get_service
p res.status # => 200

# filter
res = oss.get_service(prefix: 'abc-')
```

#### Delete a bucket
Note: only empty bucket can be deleted. If you want to delete a bucket that has objects inside, you have to delete all the objects first.

```ruby
# method signature
delete_bucket(name)
```

```ruby
res = oss.delete_bucket('bucket-name')
p res.status # => 204
```

#### Get location of a bucket
You can get the location of a bucket through `get_bucket_location`

```ruby
# method signature
get_bucket_location(name)
```

```ruby
res = oss.get_bucket_location('bucket-name')
p res.status # => 204
p res.xpath("//LocationConstraint") # => 'oss-cn-hangzhou'
```

#### Manage permissions of a bucket
You can change the permission of a bucket after the creation.

```ruby
# method signature
put_bucket_acl(name, permission)
```
Acceptable `permission`: 'public-read-write', 'public-read', 'private'.

```ruby
res = oss.put_bucket_acl('bucket-name', 'public-read-write')
p res.status # => 200
```

Get the current permission of a bucket can be done throuth `get_bucket_acl`.
```ruby
# method signature
get_bucket_acl(name)
```

```ruby
res = oss.get_bucket_acl('bucket-name')
p res.status # => 200
p res.xpath("//Grant") # => 'public-read-write'
```
