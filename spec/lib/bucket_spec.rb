require 'spec_helper'

describe "Bucket API" do
  before :each do
    @endpoint = 'oss-cn-hangzhou.aliyuncs.com'
    @access_key_id = 'ACCESS_KEY_ID'
    @access_key_secret = 'ACCESS_KEY_SECRET'
    @oss = OSS.new({
      endpoint: @endpoint,
      access_key_id: @access_key_id,
      access_key_secret: @access_key_secret
    })
    @bucket_name = 'oss-ruby-sdk-test-bucket'
    @non_exist_bucket = 'non-exist-bucket'
  end

  describe "#get_service" do
    before do
      stub_request(:get, @endpoint)
        .to_return(
          status: 200,
          body: File.read('spec/fixtures/get_service.xml')
        )
    end

    it "list bucket list" do
      response = @oss.get_service
      expect(response.status).to eq(200)
      expect(response.xpath("//ID").text).to be_a(String)
    end
  end

  describe "#put_bucket" do
    before do
      @permission = 'private'
      @region = 'oss-cn-hangzhou'
      stub_request(:put, "#{@bucket_name}.#{@endpoint}")
        .with(
          headers: {'x-oss-acl' => @permission},
          body: hash_including(
            'CreateBucketConfiguration' => {'LocationConstraint' => @region}
          )
        )
        .to_return(status: 200)
    end

    it "create bucket on location hangzhou" do
      response = @oss.put_bucket(@bucket_name, @permission, @region)
      expect(response.status).to eq(200)
    end
  end

  describe "#get_bucket" do
    before do
      stub_request(:get, "#{@bucket_name}.#{@endpoint}")
        .to_return(status: 200, body: File.read('spec/fixtures/get_bucket.xml'))
      stub_request(:get, "#{@non_exist_bucket}.#{@endpoint}")
        .to_return(status: 404)
    end

    it "get bucket information" do
      response = @oss.get_bucket(@bucket_name)
      expect(response.status).to eq(200)
      expect(response.xpath("//Name").text).to eq(@bucket_name)
    end

    it "return NoSuchBucket when bucket does not exist" do
      response = @oss.get_bucket(@non_exist_bucket)
      expect(response.status).to eq(404)
    end
  end

  describe "#delete_bucket" do
    before do
      stub_request(:delete, "#{@bucket_name}.#{@endpoint}")
        .to_return(status: 204)
      stub_request(:delete, "#{@non_exist_bucket}.#{@endpoint}")
        .to_return(status: 404)
    end
    it "get bucket information" do
      response = @oss.delete_bucket(@bucket_name)
      expect(response.status).to eq(204)
    end

    it "return NoSuchBucket when bucket does not exist" do
      response = @oss.delete_bucket(@non_exist_bucket)
      expect(response.status).to eq(404)
    end
  end

  describe "Sub Resource: ACL Location Logging Website Referer Lifecycle" do
    context "#ACL" do
      before do
        @permission = 'private'
        stub_request(:put, "#{@bucket_name}.#{@endpoint}/?acl")
          .with(headers: {'x-oss-acl' => @permission})
          .to_return(status: 200)
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?acl")
          .to_return(status: 200, body: File.read('spec/fixtures/get_bucket_acl.xml'))
      end

      it "modify ACL" do
        response = @oss.put_bucket_acl(@bucket_name, @permission)
        expect(response.status).to eq(200)
      end

      it "get ACL" do
        response = @oss.get_bucket_acl(@bucket_name)
        expect(response.status).to eq(200)
        expect(response.xpath("//Grant").text).to eq(@permission)
      end
    end

    context "#Location" do
      before do
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?location")
          .to_return(status: 200)
      end

      it "get location" do
        response = @oss.get_bucket_location(@bucket_name)
        expect(response.status).to eq(200)
      end
    end

    context "#Logging" do
      before do
        stub_request(:put, "#{@bucket_name}.#{@endpoint}/?logging")
          .with(
            headers: {'Content-Type' => 'application/xml'},
            body: hash_including(
              'BucketLoggingStatus' => {
                'LoggingEnabled' => {'TargetBucket' => @bucket_name}
              }
            )
          )
          .to_return(status: 200)
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?logging")
          .to_return(status: 200)
        stub_request(:delete, "#{@bucket_name}.#{@endpoint}/?logging")
          .to_return(status: 204)
      end

      it "enable logging" do
        response = @oss.put_bucket_logging(@bucket_name, @bucket_name)
        expect(response.status).to eq(200)
      end

      it "get logging" do
        response = @oss.get_bucket_logging(@bucket_name)
        expect(response.status).to eq(200)
      end

      it "delete logging" do
        response = @oss.delete_bucket_logging(@bucket_name)
        expect(response.status).to eq(204)
      end
    end

    context "#Website" do
      before do
        stub_request(:put, "#{@bucket_name}.#{@endpoint}/?website")
          .with(
            headers: {'Content-Type' => 'application/xml'},
            body: hash_including(
              'WebsiteConfiguration' => {
                'IndexDocument' => {'Suffix' => 'index.html'},
                'ErrorDocument' => {'Key' => '400.html'}
              }
            )
          )
          .to_return(status: 200)
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?website")
          .to_return(status: 200)
        stub_request(:delete, "#{@bucket_name}.#{@endpoint}/?website")
          .to_return(status: 204)
      end

      it "create website" do
        response = @oss.put_bucket_website(@bucket_name, 'index.html', '400.html')
        expect(response.status).to eq(200)
      end

      it "get website" do
        response = @oss.get_bucket_website(@bucket_name)
        expect(response.status).to eq(200)
      end

      it "delete website" do
        response = @oss.delete_bucket_website(@bucket_name)
        expect(response.status).to eq(204)
      end
    end

    context "#Referer" do
      before do
        stub_request(:put, "#{@bucket_name}.#{@endpoint}/?referer")
          .with(
            headers: {'Content-Type' => 'application/xml'},
            body: hash_including(
              'RefererConfiguration' => {
                'AllowEmptyReferer' => 'true',
                'RefererList' => {'Referer' => 'http://www.aliyun.com'}
              }
            )
          )
          .to_return(status: 200)
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?referer")
          .to_return(status: 200)
      end

      it "modify referer" do
        response = @oss.put_bucket_referer(@bucket_name, true, ['http://www.aliyun.com'])
        expect(response.status).to eq(200)
      end

      it "get referer" do
        response = @oss.get_bucket_referer(@bucket_name)
        expect(response.status).to eq(200)
      end
    end

    context "#Lifecycle" do
      before do
        stub_request(:put, "#{@bucket_name}.#{@endpoint}/?lifecycle")
          .with(
            headers: {'Content-Type' => 'application/xml'},
            body: hash_including(
              'LifecycleConfiguration' => {
                'Rule' => {
                  'ID' => 'abc prefix expiration rule',
                  'Prefix' => 'abc-',
                  'Status' => 'Enabled',
                  'Expiration' => {'Days' => '5'}
                }
              }
            )
          )
          .to_return(status: 200)
        stub_request(:get, "#{@bucket_name}.#{@endpoint}/?lifecycle")
          .to_return(status: 200)
        stub_request(:delete, "#{@bucket_name}.#{@endpoint}/?lifecycle")
          .to_return(status: 204)
      end

      it "modify lifecycle" do
        response = @oss.put_bucket_lifecycle(@bucket_name, [{
          status: 'Enabled',
          days: 5,
          prefix: 'abc-',
          id: 'abc prefix expiration rule'
        }])
        expect(response.status).to eq(200)
      end

      it "get lifecycle" do
        response = @oss.get_bucket_lifecycle(@bucket_name)
        expect(response.status).to eq(200)
      end

      it "delete lifecycle" do
        response = @oss.delete_bucket_lifecycle(@bucket_name)
        expect(response.status).to eq(204)
      end
    end
  end
end
