require 'spec_helper'

describe OSS::Response do
  before do
    response = Faraday::Response.new
    @response = OSS::Response.new(response)
  end

  it "respond to methods" do
    expect(@response).to respond_to(:response)
    expect(@response).to respond_to(:body)
    expect(@response).to respond_to(:headers)
    expect(@response).to respond_to(:status)
    expect(@response).to respond_to(:doc)
    expect(@response).to respond_to(:xpath)
  end

  context "receive an api error" do
    before do
      body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error>\n" \
            "<Code>NoSuchBucket</Code>\n  <Message>The specified bucket " \
            "does not exist.</Message>\n  <RequestId>56482B096078C074024EA8A6" \
            "</RequestId>\n  <HostId>test-bucket-2a.oss-cn-hangzhou.aliyuncs." \
            "com</HostId>\n  <BucketName>test-bucket-2a</BucketName>\n</Error>\n"
      allow(@response).to receive(:status) { 400 }
      allow(@response).to receive(:doc) { Nokogiri::XML(body) }
    end

    it "respond to methods" do
      expect(@response.error).to be_instance_of(OSS::APIError)
      expect(@response.error).to respond_to(:code)
      expect(@response.error).to respond_to(:message)
      expect(@response.error).to respond_to(:request_id)
      expect(@response.error).to respond_to(:host_id)
    end

    it "has error message and code" do
      expect(@response.error.code).to eq('NoSuchBucket')
      expect(@response.error.message).to eq('The specified bucket does not exist.')
    end
  end
end
