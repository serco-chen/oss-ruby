require 'mime/types'

module OSS
  class Object < Service
    def put_object(bucket, object, body, headers = {})
      headers['Content-Type'] ||= 'binary/octet-stream'
      headers['Content-Length'] = body.length.to_s
      options = setup_options(bucket, object)
      client(options).run :put, "/#{object}", body, headers
    end

    def put_object_from_file(bucket, object, file, headers = {})
      body = File.read(file)
      if mime_type = MIME::Types.type_for(file).first
        headers['Content-Type'] = mime_type.content_type
      end
      put_object(bucket, object, body, headers)
    end

    def copy_object(source_bucket, source_name, target_bucket, target_name, headers = {})
      headers['x-oss-copy-source'] = "/#{source_bucket}/#{source_name}"
      options = setup_options(target_bucket, target_name)
      client(options).run :put, "/#{target_name}", nil, headers
    end

    def get_object(bucket, object, headers = {})
      options = setup_options(bucket, object)
      client(options).run :get, "/#{object}", nil, headers
    end

    def append_object(bucket, object, body, position = 0, headers = {})
      headers['Content-Type'] ||= 'binary/octet-stream'
      headers['Content-Length'] = body.length.to_s
      options = setup_options(bucket, object, ['append', "position=#{position}"])
      client(options).run :post, "/#{object}?append&position=#{position}", body, headers
    end

    def delete_object(bucket, object)
      options = setup_options(bucket, object)
      client(options).run :delete, "/#{object}"
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
