require 'mime/types'

module OSS
  class Object < Service
    def put_object(bucket, object, body, headers = {})
      headers['Content-Type'] ||= 'binary/octet-stream'
      headers['Content-Length'] = body.length.to_s
      options = setup_options(bucket, object)
      client(options).run :put, object, body, headers
    end

    def put_object_from_file(bucket, object, file, headers = {})
      body = File.read(file)
      if mime_type = MIME::Types.type_for(file).first
        headers['Content-Type'] = mime_type.content_type
      end
      put_object(bucket, object, body, headers)
    end

    def copy_object(source_bucket, source_object, target_bucket, target_object, headers = {})
      headers['x-oss-copy-source'] = "/#{source_bucket}/#{source_object}"
      options = setup_options(target_bucket, target_object)
      client(options).run :put, target_object, nil, headers
    end

    def get_object(bucket, object, headers = {})
      options = setup_options(bucket, object)
      client(options).run :get, object, nil, headers
    end

    def append_object(bucket, object, body, position = 0, headers = {})
      headers['Content-Type'] ||= 'binary/octet-stream'
      headers['Content-Length'] = body.length.to_s
      options = setup_options(bucket, object, ['append', "position=#{position}"])
      client(options).run :post, "#{object}?append&position=#{position}", body, headers
    end

    def delete_object(bucket, object)
      options = setup_options(bucket, object)
      client(options).run :delete, object
    end

    def delete_multiple_objects(bucket, objects, quiet = false)
      body = '<?xml version="1.0" encoding="UTF-8"?><Delete>' \
             "<Quiet>#{quiet}</Quiet>"
      objects.each do |object|
        body += "<Object><Key>#{object}</Key></Object>"
      end
      body += '</Delete>'

      headers = {
        'Content-Length' => body.length.to_s,
        'Content-MD5' => OSS::Utils.content_md5_header(body),
        'Content-Type' => 'application/xml'
      }

      options = setup_options(bucket, nil, 'delete')
      client(options).run :post, '?delete', body, headers
    end

    def head_object(bucket, object, headers = {})
      options = setup_options(bucket, object)
      client(options).run :head, object, nil, headers
    end

    # permission: public-read-write，public-read, private
    def put_object_acl(bucket, object, permission)
      headers = {
        'x-oss-object-acl' => permission
      }
      options = setup_options(bucket, object, 'acl')
      client(options).run :put, "#{object}?acl", nil, headers
    end

    def get_object_acl(bucket, object)
      options = setup_options(bucket, object, 'acl')
      client(options).run :get, object, 'acl' => nil
    end

    def init_multi_upload(bucket, object, headers = {})
      options = setup_options(bucket, object, 'uploads')
      client(options).run :post, "#{object}?uploads", nil, headers
    end

    def upload_object_part(bucket, object, body, upload_id, part = 1)
      headers = {
        'Content-Length' => body.length.to_s,
        'Content-MD5' => OSS::Utils.content_md5_header(body),
        'Content-Type' => 'binary/octet-stream'
      }
      options = setup_options(bucket, object, ["partNumber=#{part}", "uploadId=#{upload_id}"])
      client(options).run :put, "#{object}?partNumber=#{part}&uploadId=#{upload_id}", body, headers
    end

    def upload_object_part_copy(source_bucket, source_object, target_bucket, target_object, upload_id, part = 1, headers = {})
      headers['x-oss-copy-source'] = "/#{source_bucket}/#{source_object}"
      options = setup_options(target_bucket, target_object, ["partNumber=#{part}", "uploadId=#{upload_id}"])
      client(options).run :put, "#{target_object}?partNumber=#{part}&uploadId=#{upload_id}", nil, headers
    end

    def complete_multi_upload(bucket, object, upload_id, parts = [])
      body = '<?xml version="1.0" encoding="UTF-8"?><CompleteMultipartUpload>'
      parts.each do |part|
        body += "<Part><PartNumber>#{part[:part_number]}</PartNumber><ETag>#{part[:etag]}</ETag></Part>"
      end
      body += '</CompleteMultipartUpload>'

      headers = {
        'Content-Type' => 'application/xml'
      }

      options = setup_options(bucket, object, "uploadId=#{upload_id}")
      client(options).run :post, "#{object}?uploadId=#{upload_id}", body, headers
    end

    def abort_multi_upload(bucket, object, upload_id)
      options = setup_options(bucket, object, "uploadId=#{upload_id}")
      client(options).run :delete, "#{object}?uploadId=#{upload_id}"
    end

    def list_multi_upload(bucket, headers = {})
      options = setup_options(bucket, nil, 'uploads')
      client(options).run :get, '/', { 'uploads' => nil }, headers
    end

    def list_object_parts(bucket, object, upload_id, headers = {})
      options = setup_options(bucket, object, "uploadId=#{upload_id}")
      client(options).run :get, object, { 'uploadId' => upload_id }, headers
    end

    private

    def setup_options(bucket, object = nil, sub_resource = nil)
      {
        subdomain: bucket,
        resource: "/#{bucket}/#{object}",
        sub_resource: sub_resource
      }
    end
  end
end
