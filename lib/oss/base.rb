module OSS
  class Base
    extend Forwardable
    attr_reader :config

    def initialize(options = {})
      @config = OSS::Config.new(
        OSS::Utils.indifferent_hash(options)
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

    def_delegators :object,
                   :put_object,
                   :put_object_from_file,
                   :copy_object,
                   :get_object,
                   :append_object,
                   :delete_object,
                   :delete_multiple_objects,
                   :head_object,
                   :get_object_meta,
                   :put_object_acl,
                   :get_object_acl,
                   :post_object,
                   :init_multi_upload,
                   :upload_object_part,
                   :upload_object_part_copy,
                   :complete_multi_upload,
                   :abort_multi_upload,
                   :list_multi_upload,
                   :list_object_parts

    private

    def bucket
      @bucket ||= OSS::Bucket.new(config)
    end

    def object
      @object ||= OSS::Object.new(config)
    end
  end
end
