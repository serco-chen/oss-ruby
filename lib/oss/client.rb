require 'base64'
require 'time'

module OSS
  class Client
    OSS_HEADER_PREFIX = 'x-oss-'
    attr_reader :config, :options

    def initialize(config, options = {})
      @config = config
      @options = options
    end

    def run(verb, url, params = {}, headers = {})
      headers['Date'] = Time.now.httpdate
      if !headers['Content-Type'] && (verb == :put || verb == :post)
        headers['Content-Type'] = "application/x-www-form-urlencoded"
      end
      headers['Authorization'] = authorization_string(verb, headers)
      response = connection.send verb do |conn|
        conn.url url
        conn.headers = headers
        if verb == :get && params
          conn.params = params
        elsif (verb == :put || verb == :post) && params
          conn.body = params
        end
      end
      OSS::Response.new(response)
    rescue Faraday::ClientError => e
      raise OSS::HTTPClientError.new(e)
    end

    # "Authorization: OSS " + Access Key Id + ":" + Signature
    def authorization_string(verb, headers)
      data = [
        verb.to_s.upcase,
        headers['Content-MD5'],
        headers['Content-Type'],
        headers['Date']
      ]

      # Calculate OSS Headers
      if headers.keys.any? { |key| key.to_s.downcase.start_with?('x-oss-') }
        oss_headers = headers
          .select { |k, _| k.to_s.downcase.start_with?('x-oss-') }
          .map { |k, v| k.to_s.downcase.strip + ':' + v.strip }
          .sort
          .join("\n")
        data.push oss_headers
      end

      # Calculate Canonicalized Resource
      canonicalized_resource = options[:resource] ? options[:resource] : '/'
      if options[:sub_resource]
        options[:sub_resource] = [options[:sub_resource]] unless options[:sub_resource].is_a?(Array)
        query = options[:sub_resource].map(&:to_s).sort.join("&")
        canonicalized_resource += "?#{query}"
      end
      data.push canonicalized_resource

      "OSS " + config.access_key_id + ":" + sign(data.join("\n"))
    end

    # Signature = base64(hmac-sha1(AccessKeySecret,
    #             VERB + "\n"
    #             + CONTENT-MD5 + "\n"
    #             + CONTENT-TYPE + "\n"
    #             + DATE + "\n"
    #             + CanonicalizedOSSHeaders
    #             + CanonicalizedResource))
    def sign(data)
      key = config.access_key_secret
      digest = OpenSSL::Digest.new('sha1')
      hmac = OpenSSL::HMAC.digest(digest, key, data)
      Base64.encode64(hmac).strip
    end

    def connection
      endpoint = options[:subdomain] ? "#{options[:subdomain]}.#{config.endpoint}" : config.endpoint
      @connection = Faraday.new(url: 'http://' + endpoint) do |conn|
        conn.request  :url_encoded
        conn.response :logger
        conn.adapter  Faraday.default_adapter
      end
    end
  end
end
