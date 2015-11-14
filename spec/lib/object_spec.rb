require 'spec_helper'

describe "Object API" do
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
    @object_name = 'oss-ruby-sdk-test-object'
    @non_exist_bucket = 'non-exist-bucket'
    @non_exist_object = 'non-exist-object'
  end

  describe "#put_object #put_object_from_file" do
    before do
      @body = File.read('spec/fixtures/test.txt')
      stub_request(:put, "#{@bucket_name}.#{@endpoint}/#{@object_name}")
        .with(headers: {'Content-Length' => @body.length.to_s}, body: @body)
        .to_return(status: 200)
      stub_request(:put, "#{@non_exist_bucket}.#{@endpoint}/#{@object_name}")
        .with(headers: {'Content-Length' => @body.length.to_s}, body: @body)
        .to_return(status: 404)
    end

    it "create object on bucket with file content given" do
      response = @oss.put_object(@bucket_name, @object_name, File.read('spec/fixtures/test.txt'))
      expect(response.status).to eq(200)
    end

    it "create object on bucket with file name specified" do
      response = @oss.put_object_from_file(@bucket_name, @object_name, 'spec/fixtures/test.txt')
      expect(response.status).to eq(200)
    end

    it "create object on non existed bucket will return 404" do
      response = @oss.put_object(@non_exist_bucket, @object_name, File.read('spec/fixtures/test.txt'))
      expect(response.status).to eq(404)
    end
  end

  describe "#copy_object" do
    before do
      stub_request(:put, "#{@bucket_name}.#{@endpoint}/#{@object_name}")
        .with(headers: {'x-oss-copy-source' => "/#{@bucket_name}/source-file-name"})
        .to_return(status: 200)
    end

    it "copy object on bucket" do
      response = @oss.copy_object(@bucket_name, 'source-file-name', @bucket_name, @object_name)
      expect(response.status).to eq(200)
    end
  end

  describe "#get_object" do
    before do
      stub_request(:get, "#{@bucket_name}.#{@endpoint}/#{@object_name}")
        .to_return(status: 200)
    end

    it "read object from bucket" do
      response = @oss.get_object(@bucket_name, @object_name)
      expect(response.status).to eq(200)
    end
  end

  describe "#append_object" do
    before do
      stub_request(:post, "#{@bucket_name}.#{@endpoint}/#{@object_name}?append&position=0")
        .with(body: 'append content')
        .to_return(status: 200, headers: {'x-oss-next-append-position' => '14'})
    end

    it "append object on bucket" do
      response = @oss.append_object(@bucket_name, @object_name, 'append content')
      expect(response.status).to eq(200)
      expect(response.headers['x-oss-next-append-position']).to eq('14')
    end
  end

  describe "#delete_object" do
    before do
      stub_request(:delete, "#{@bucket_name}.#{@endpoint}/#{@object_name}")
        .to_return(status: 204)
    end

    it "delete object from bucket" do
      response = @oss.delete_object(@bucket_name, @object_name)
      expect(response.status).to eq(204)
    end
  end

  describe "#delete_multiple_objects" do
    before do
      stub_request(:post, "#{@bucket_name}.#{@endpoint}/?delete")
        .with(
          body: hash_including(
            'Delete' => {'Quiet' => 'false', 'Object' => {'Key' => @object_name}}
          )
        )
        .to_return(status: 200)
    end

    it "delete multiple objects from bucket" do
      response = @oss.delete_multiple_objects(@bucket_name, [@object_name])
      expect(response.status).to eq(200)
    end
  end

  describe "#head_object" do
    before do
      stub_request(:head, "#{@bucket_name}.#{@endpoint}/#{@object_name}")
        .to_return(status: 200, headers: {'x-oss-object-type' => 'Normal'})
    end

    it "read object meta information from bucket" do
      response = @oss.head_object(@bucket_name, @object_name)
      expect(response.status).to eq(200)
      expect(response.headers['x-oss-object-type']).to eq('Normal')
    end
  end

  describe "#put_object_acl" do
    before do
      @permission = 'private'
      stub_request(:put, "#{@bucket_name}.#{@endpoint}/#{@object_name}?acl")
        .with(headers: {'x-oss-object-acl' => @permission})
        .to_return(status: 200)
    end

    it "modify object ACL on bucket" do
      response = @oss.put_object_acl(@bucket_name, @object_name, @permission)
      expect(response.status).to eq(200)
    end
  end

  describe "#get_object_acl" do
    before do
      @permission = 'private'
      stub_request(:get, "#{@bucket_name}.#{@endpoint}/#{@object_name}?acl")
        .to_return(status: 200, body: File.read('spec/fixtures/get_object_acl.xml'))
    end

    it "modify object ACL on bucket" do
      response = @oss.get_object_acl(@bucket_name, @object_name)
      expect(response.status).to eq(200)
      expect(response.xpath("//Grant").text).to eq(@permission)
    end
  end

  describe "#init_multi_upload" do
    before do
      stub_request(:post, "#{@bucket_name}.#{@endpoint}/#{@object_name}?uploads")
        .to_return(status: 200, body: File.read('spec/fixtures/init_multi_upload.xml'))
    end

    it "initialize multipart upload event on bucket" do
      response = @oss.init_multi_upload(@bucket_name, @object_name)
      expect(response.status).to eq(200)
      expect(response.xpath("//UploadId").text).to be_instance_of(String)
    end
  end

  describe "#upload_object_part" do
    before do
      @upload_id = '0004B9894A22E5B1888A1E29F8236E2D'
      stub_request(:put, "#{@bucket_name}.#{@endpoint}/#{@object_name}?partNumber=1&uploadId=#{@upload_id}")
        .with(body: File.read('spec/fixtures/test.txt'))
        .to_return(status: 200, headers: {'ETag' => '7265F4D211B56873A381D321F586E4A9'})
    end

    it "upload object part on bucket" do
      response = @oss.upload_object_part(@bucket_name, @object_name, File.read('spec/fixtures/test.txt'), @upload_id)
      expect(response.status).to eq(200)
      expect(response.headers['ETag']).to be_instance_of(String)
    end
  end

  describe "#upload_object_part_copy" do
    before do
      @upload_id = '0004B9894A22E5B1888A1E29F8236E2D'
      stub_request(:put, "#{@bucket_name}.#{@endpoint}/#{@object_name}?partNumber=1&uploadId=#{@upload_id}")
        .with(headers: {'x-oss-copy-source' => "/#{@bucket_name}/source-file-name"})
        .to_return(status: 200, body: File.read('spec/fixtures/upload_object_part_copy.xml'))
    end

    it "copy upload object part on bucket" do
      response = @oss.upload_object_part_copy(@bucket_name, 'source-file-name', @bucket_name, @object_name, @upload_id)
      expect(response.status).to eq(200)
      expect(response.xpath("//ETag").text).to be_instance_of(String)
    end
  end

  describe "#complete_multi_upload" do
    before do
      @upload_id = '0004B9894A22E5B1888A1E29F8236E2D'
      stub_request(:post, "#{@bucket_name}.#{@endpoint}/#{@object_name}?uploadId=#{@upload_id}")
        .with(
          body: hash_including(
            'CompleteMultipartUpload' => {
              'Part' => {
                'PartNumber' => '1',
                'ETag' => '7265F4D211B56873A381D321F586E4A9'
              }
            }
          )
        )
        .to_return(status: 200, body: File.read('spec/fixtures/complete_multi_upload.xml'))
    end

    it "complete multiple part upload event on bucket" do
      response = @oss.complete_multi_upload(
        @bucket_name,
        @object_name,
        @upload_id, [{
          part_number: 1,
          etag: "7265F4D211B56873A381D321F586E4A9"
        }]
      )
      expect(response.status).to eq(200)
      expect(response.xpath("//Key").text).to eq(@object_name)
    end
  end

  describe "#abort_multi_upload" do
    before do
      @upload_id = '0004B9894A22E5B1888A1E29F8236E2D'
      stub_request(:delete, "#{@bucket_name}.#{@endpoint}/#{@object_name}?uploadId=#{@upload_id}")
        .to_return(status: 204)
    end

    it "abort multipart upload event on bucket" do
      response = @oss.abort_multi_upload(@bucket_name, @object_name, @upload_id)
      expect(response.status).to eq(204)
    end
  end

  describe "#list_multi_upload" do
    before do
      stub_request(:get, "#{@bucket_name}.#{@endpoint}/?uploads")
        .to_return(status: 200, body: File.read('spec/fixtures/list_multi_upload.xml'))
    end

    it "list multipart upload events on bucket" do
      response = @oss.list_multi_upload(@bucket_name)
      expect(response.status).to eq(200)
      expect(response.xpath("//Bucket").text).to eq(@bucket_name)
    end
  end

  describe "#list_object_parts" do
    before do
      @upload_id = '0004B9894A22E5B1888A1E29F8236E2D'
      stub_request(:get, "#{@bucket_name}.#{@endpoint}/#{@object_name}?uploadId=#{@upload_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/list_object_parts.xml'))
    end

    it "list multiple upload object parts of specified upload id on bucket" do
      response = @oss.list_object_parts(@bucket_name, @object_name, @upload_id)
      expect(response.status).to eq(200)
      expect(response.xpath("//Bucket").text).to eq(@bucket_name)
    end
  end
end
