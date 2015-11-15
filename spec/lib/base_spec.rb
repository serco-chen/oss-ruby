require 'spec_helper'

describe OSS::Base do
  before do
    @oss = OSS::Base.new({
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      access_key_id: 'ACCESS_KEY_ID',
      access_key_secret: 'ACCESS_KEY_SECRET'
    })
  end

  it "respond to api methods" do
    expect(@oss).to respond_to(:get_service)
    expect(@oss).to respond_to(:put_bucket)
    expect(@oss).to respond_to(:put_bucket_acl)
    expect(@oss).to respond_to(:put_bucket_logging)
    expect(@oss).to respond_to(:put_bucket_website)
    expect(@oss).to respond_to(:put_bucket_referer)
    expect(@oss).to respond_to(:put_bucket_lifecycle)
    expect(@oss).to respond_to(:get_bucket)
    expect(@oss).to respond_to(:get_bucket_acl)
    expect(@oss).to respond_to(:get_bucket_location)
    expect(@oss).to respond_to(:get_bucket_logging)
    expect(@oss).to respond_to(:get_bucket_website)
    expect(@oss).to respond_to(:get_bucket_referer)
    expect(@oss).to respond_to(:get_bucket_lifecycle)
    expect(@oss).to respond_to(:delete_bucket)
    expect(@oss).to respond_to(:delete_bucket_logging)
    expect(@oss).to respond_to(:delete_bucket_website)
    expect(@oss).to respond_to(:delete_bucket_lifecycle)
    expect(@oss).to respond_to(:put_bucket_cors)
    expect(@oss).to respond_to(:get_bucket_cors)
    expect(@oss).to respond_to(:delete_bucket_cors)

    expect(@oss).to respond_to(:put_object)
    expect(@oss).to respond_to(:put_object_from_file)
    expect(@oss).to respond_to(:copy_object)
    expect(@oss).to respond_to(:get_object)
    expect(@oss).to respond_to(:append_object)
    expect(@oss).to respond_to(:delete_object)
    expect(@oss).to respond_to(:delete_multiple_objects)
    expect(@oss).to respond_to(:head_object)
    expect(@oss).to respond_to(:put_object_acl)
    expect(@oss).to respond_to(:get_object_acl)
    expect(@oss).to respond_to(:post_object)
    expect(@oss).to respond_to(:init_multi_upload)
    expect(@oss).to respond_to(:upload_object_part)
    expect(@oss).to respond_to(:upload_object_part_copy)
    expect(@oss).to respond_to(:complete_multi_upload)
    expect(@oss).to respond_to(:abort_multi_upload)
    expect(@oss).to respond_to(:list_multi_upload)
    expect(@oss).to respond_to(:list_object_parts)
  end

  context "#bucket" do
    it "returns instance of OSS::Bucket" do
      expect(@oss.send :bucket).to be_instance_of(OSS::Bucket)
    end
  end

  context "#object" do
    it "returns instance of OSS::Object" do
      expect(@oss.send :object).to be_instance_of(OSS::Object)
    end
  end
end
