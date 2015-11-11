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

    private

    def setup_options(bucket, object, sub_resource = nil)
      {
        subdomain: bucket,
        resource: "/#{bucket}/#{object}",
        sub_resource: sub_resource
      }
    end
  end
end
