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

    def_delegators :bucket, :get_service, :put_bucket, :put_bucket_acl,
      :put_bucket_logging

    private

    def bucket
      OSS::Bucket.new(config)
    end
  end
end
