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

    def put_bucket_logging(source, target = nil, prefix = nil)
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

    def put_bucket_website(name, index, error)
      body = '<?xml version="1.0" encoding="UTF-8"?><WebsiteConfiguration>' \
             "<IndexDocument><Suffix>#{index}</Suffix></IndexDocument>"
      if error
        body += "<ErrorDocument><Key>#{error}</Key></ErrorDocument>"
      end
      body += '</WebsiteConfiguration>'

      headers = {
        'Content-Type' => 'application/xml'
      }

      setup_bucket_options(name, 'website')
      client.run :put, '?website', body, headers
    end

    def put_bucket_website(name, index, error)
      body = '<?xml version="1.0" encoding="UTF-8"?><WebsiteConfiguration>' \
             "<IndexDocument><Suffix>#{index}</Suffix></IndexDocument>"
      if error
        body += "<ErrorDocument><Key>#{error}</Key></ErrorDocument>"
      end
      body += '</WebsiteConfiguration>'

      headers = {
        'Content-Type' => 'application/xml'
      }

      setup_bucket_options(name, 'website')
      client.run :put, '?website', body, headers
    end

    def put_bucket_referer(name, allow_empty_referer, referers=[])
      body = '<?xml version="1.0" encoding="UTF-8"?><RefererConfiguration>' \
             "<AllowEmptyReferer>#{allow_empty_referer}</AllowEmptyReferer >" \
             "<RefererList>"
      referers.each do |referer|
        body += "<Referer>#{referer}</Referer>"
      end
      body += '</RefererList></RefererConfiguration>'

      headers = {
        'Content-Type' => 'application/xml'
      }

      setup_bucket_options(name, 'referer')
      client.run :put, '?referer', body, headers
    end

    # status: Enabled, Disabled
    def put_bucket_lifecycle(name, rules=[])
      body = '<?xml version="1.0" encoding="UTF-8"?><LifecycleConfiguration>'
      rules.each do |rule|
        rule_content = '<Rule>'
        rule_content += "<ID>#{rule[:id]}</ID>" if rule[:id]
        rule_content += "<Prefix>#{rule[:prefix]}</Prefix>" if rule[:prefix]
        rule_content += "<Status>#{rule[:status]}</Status>"
        expiration =
          if rule[:days]
            "<Days>#{rule[:days]}</Days>"
          else
            "<Date>#{rule[:date]}</Date>"
          end
        rule_content += "<Expiration>#{expiration}</Expiration></Rule>"
        body += rule_content
      end

      body += '</LifecycleConfiguration>'

      headers = {
        'Content-Type' => 'application/xml'
      }

      setup_bucket_options(name, 'lifecycle')
      client.run :put, '?lifecycle', body, headers
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
