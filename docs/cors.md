# Cross-Origin Resource Sharing API

Cross-Origin Resource Sharing allows Javascript scripts from other origins be able to access resources in a specific bucket.

* Cross-Origin Resource Sharing
  * Setup CORS rules of a bucket
  * Get CORS rules of a bucket
  * Delete CORS rules of a bucket

#### Setup CORS rules of a bucket
Rules can be set through `put_bucket_cors`. A bucket can have at most 10 rules.
See details spec of a rule in [API doc](https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors)

```ruby
# method signature
put_bucket_cors(name, rules)
```
```ruby
res = oss.put_bucket_cors(
  'bucket-name',
  [{
    'AllowedOrigin' => '*',
    'AllowedMethod' => ['PUT', 'GET'],
    'AllowedHeader' => 'Authorization'
  }, {
    'AllowedOrigin' => ['http://www.a.com', 'http://www.b.com'],
    'AllowedMethod' => 'GET',
    'AllowedHeader' => 'Authorization',
    'ExposeHeader'  => ['x-oss-test', 'x-oss-test1'],
    'MaxAgeSeconds' => 100
  }]
)
p res.status # => 200
```

#### Get CORS rules of a bucket

```ruby
# method signature
get_bucket_cors(name)
```
```ruby
res = oss.get_bucket_cors('bucket-name')
p res.status # => 200
```

#### Delete CORS rules of a bucket

```ruby
# method signature
delete_bucket_cors(name)
```
```ruby
res = oss.delete_bucket_cors('bucket-name')
p res.status # => 200
```
