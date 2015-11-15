module OSS
  class Bucket < Service
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
      options = setup_options(name)
      client(options).run :put, '/', body, headers
    end

    # permission: public-read-write，public-read, private
    def put_bucket_acl(name, permission)
      headers = {
        'x-oss-acl' => permission
      }
      options = setup_options(name, 'acl')
      client(options).run :put, '?acl', nil, headers
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
      options = setup_options(source, 'logging')
      client(options).run :put, '?logging', body, headers
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

      options = setup_options(name, 'website')
      client(options).run :put, '?website', body, headers
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

      options = setup_options(name, 'website')
      client(options).run :put, '?website', body, headers
    end

    def put_bucket_referer(name, allow_empty_referer = true, referers=[])
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

      options = setup_options(name, 'referer')
      client(options).run :put, '?referer', body, headers
    end

    # status: Enabled, Disabled
    def put_bucket_lifecycle(name, rules = [])
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

      options = setup_options(name, 'lifecycle')
      client(options).run :put, '?lifecycle', body, headers
    end

    # params keys: prefix, marker, delimiter, max-keys, encoding-type
    def get_bucket(name, params = {})
      options = setup_options(name)
      client(options).run :get, '/', params
    end

    [:acl, :location, :logging, :website, :referer, :lifecycle, :cors].each do |sub_resource|
      define_method("get_bucket_#{sub_resource}".to_sym) do |name|
        get_bucket_sub_resource(name, sub_resource)
      end
    end

    def delete_bucket(name)
      options = setup_options(name)
      client(options).run :delete, '/'
    end

    [:logging, :website, :lifecycle, :cors].each do |sub_resource|
      define_method("delete_bucket_#{sub_resource}".to_sym) do |name|
        delete_bucket_sub_resource(name, sub_resource)
      end
    end

    def put_bucket_cors(name, rules)
      body = '<?xml version="1.0" encoding="UTF-8"?><CORSConfiguration>'
      rules.each do |rule|
        rule_content = '<CORSRule>'
        rule_content += cors_rule_content_generator(rule, 'AllowedOrigin')
        rule_content += cors_rule_content_generator(rule, 'AllowedMethod')
        rule_content += cors_rule_content_generator(rule, 'AllowedHeader')
        rule_content += cors_rule_content_generator(rule, 'ExposeHeader')
        rule_content += cors_rule_content_generator(rule, 'MaxAgeSeconds', false)
        rule_content += '</CORSRule>'
        body += rule_content
      end
      body += '</CORSConfiguration>'

      options = setup_options(name, 'cors')
      client(options).run :put, '?cors', body
    end

    private

    def cors_rule_content_generator(rule, key, allow_multi = true)
      options = rule[key]
      return '' unless options
      if allow_multi
        options = options.is_a?(Array) ? options : [options]
        options.reduce('') do |content, option|
          content + "<#{key}>#{option}</#{key}>"
        end
      else
        "<#{key}>#{options}</#{key}>"
      end
    end

    def delete_bucket_sub_resource(name, sub_resource)
      options = setup_options(name, sub_resource)
      client(options).run :delete, "?#{sub_resource}"
    end

    def get_bucket_sub_resource(name, sub_resource)
      options = setup_options(name, sub_resource)
      client(options).run :get, '/', "#{sub_resource}" => nil
    end

    def setup_options(bucket, sub_resource = nil)
      {
        subdomain: bucket,
        resource: "/#{bucket}/",
        sub_resource: sub_resource
      }
    end
  end
end
