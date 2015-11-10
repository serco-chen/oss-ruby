module OSS
  class Base
    include OSS::Utils
    extend Forwardable
    attr_reader :config

    def initialize(options = {})
      @config = OSS::Config.new(
        indifferent_hash(options)
      )
    end

    def_delegators :bucket,
                   :get_service,
                   :put_bucket,
                   :put_bucket_acl,
                   :put_bucket_logging,
                   :put_bucket_website,
                   :put_bucket_referer,
                   :put_bucket_lifecycle,
                   :get_bucket,
                   :get_bucket_acl,
                   :get_bucket_location,
                   :get_bucket_logging,
                   :get_bucket_website,
                   :get_bucket_referer,
                   :get_bucket_lifecycle,
                   :delete_bucket,
                   :delete_bucket_logging,
                   :delete_bucket_website,
                   :delete_bucket_lifecycle

    private

    def bucket
      OSS::Bucket.new(config)
    end
  end
end
