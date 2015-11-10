module OSS
  class Bucket
    def initialize(config)
      @config = config
      @options = {}
    end

    # params keys: prefix, marker, max-keys
    def get_service(params = {})
      client.run :get, '/', params
    end

    def put_bucket(name, permission = 'private', location = 'oss-cn-hangzhou')
      body = '<?xml version="1.0" encoding="UTF-8"?>' \
             '<CreateBucketConfiguration>' \
             "<LocationConstraint>#{location}</LocationConstraint>" \
             '</CreateBucketConfiguration>'
      headers = {
        'x-oss-acl' => permission,
        'Content-Type' => 'application/xml'
      }
      setup_bucket_options(name)
      client.run :put, '/', body, headers
    end

    # permission: public-read-write，public-read, private
    def put_bucket_acl(name, permission)
      setup_bucket_options(name, 'acl')
      headers = {
        'x-oss-acl' => permission
      }
      client.run :put, '?acl', nil, headers
    end

    def put_bucket_logging(source, target=nil, prefix=nil)
      body = '<?xml version="1.0" encoding="UTF-8"?><BucketLoggingStatus>'
      if target
        body += "<LoggingEnabled><TargetBucket>#{target}</TargetBucket>"
        body += "<TargetPrefix>#{prefix}</TargetPrefix>" if prefix
        body += '</LoggingEnabled>'
      end
      body += '</BucketLoggingStatus>'
      headers = {
        'Content-Type' => 'application/xml'
      }
      setup_bucket_options(source, 'logging')
      client.run :put, '?logging', body, headers
    end

    private

    def client
      OSS::Client.new(@config, @options)
    end

    def setup_bucket_options(name, sub_resource = nil)
      @options = {
        subdomain: name,
        resource: "/#{name}/",
        sub_resource: sub_resource
      }
    end
  end
end
