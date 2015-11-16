# Multipart Upload API

OSS service support more than one ways to upload files. Besides `put_object`, user can upload files through 'Multipart Upload'. It supports 'broken-point continuingly-transferring', so it's very suitable in these scenarios:

* Needs support of broken-point continuingly-transferring.
* Large file with size exceeded 100MB.
* Terrible Networking condition.
* File size not determined.

---

* Multipart Upload
  * Initialize a multipart upload event
  * Upload an object part
  * Copy an object part
  * Complete a multipart upload event
  * Abort a multipart upload event
  * List all multipart upload events in a bucket
  * List parts of an object

#### Initialize a multipart upload event
Before upload parts of the file you need to upload, you have to initialize a multipart upload event.
```ruby
# method signature
init_multi_upload(bucket, object, headers = {})
```
```ruby
res = oss.init_multi_upload('bucket-name', 'object-name')
p res.status # => 200
p res.xpath("//UploadId") # => '0004B9894A22E5B1888A1E29F8236E2D'
```

'UploadId' is the identifier of the multipart upload event, you'll need it later operations.

#### Upload an object part
```ruby
# method signature
upload_object_part(bucket, object, body, upload_id, part = 1)
```
```ruby
res = upload_object_part('bucket-name', 'object-name', 'String Content of Part 1', '0004B9894A22E5B1888A1E29F8236E2D', 1)
p res.status # => 200
```

#### Copy an object part
`upload_object_part_copy` allows user to copy an existed object as a part of the multipart upload object. And objects large than 1GB must be copied through this method.

Note:
  * Each part must large than 100KB except the last part.
  * Valid range of part number: 1~10000.

```ruby
# method signature
upload_object_part_copy(source_bucket, source_object, target_bucket, target_object, upload_id, part = 1, headers = {})
```
```ruby
res = upload_object_part_copy('target-bucket-name', 'target-object-name', 'target-bucket-name', 'target-object-name', '0004B9894A22E5B1888A1E29F8236E2D', 2)
p res.status # => 200
```

#### Complete a multipart upload event
After finishing uploading parts, you have to call `complete_multi_upload` to finish the multipart upload event.

```ruby
# method signature
complete_multi_upload(bucket, object, upload_id, parts = [])
```
```ruby
res = oss.complete_multi_upload(
  'bucket-name', 'object-name', '0004B9894A22E5B1888A1E29F8236E2D',
  [{
    part_number: 1,
    etag: "172F5D31191B965FE8CCB5A0F5BECD9A"
  }, {
    part_number: 2,
    etag: "172F5D31191B965FE8CCB5A0F5BECD9A"
  }]
)
p res.status # => 200
```

#### Abort a multipart upload event
Sometimes you need to abort the upload event, this is where `abort_multi_upload` come into play.

```ruby
# method signature
abort_multi_upload(bucket, object, upload_id)
```
```ruby
res = oss.abort_multi_upload('bucket-name', 'object-name', '0004B9894A22E5B1888A1E29F8236E2D')
p res.status # => 204
```

#### List all multipart upload events in a bucket
You can get all unfinished multipart upload events through `list_multi_upload`.

```ruby
# method signature
list_multi_upload(bucket, headers = {})
```
```ruby
res = oss.list_multi_upload('bucket-name')
p res.status # => 200
```

#### List parts of an object
Sometimes you need to view the parts that have been uploaded successfully during a multipart upload event.

```ruby
# method signature
list_object_parts(bucket, object, upload_id, headers = {})
```
```ruby
res = oss.list_object_parts('bucket-name', 'object-name', '0004B9894A22E5B1888A1E29F8236E2D')
p res.status # => 200
```
