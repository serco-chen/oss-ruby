require 'spec_helper'

describe OSS::Client do
  before do
    @endpoint = 'oss-cn-hangzhou.aliyuncs.com'
    @access_key_id = 'ACCESS_KEY_ID'
    @access_key_secret = 'ACCESS_KEY_SECRET'
    config = OSS::Config.new({
      endpoint: @endpoint,
      access_key_id: @access_key_id,
      access_key_secret: @access_key_secret
    })
    @client = OSS::Client.new(config)
  end

  it "respond to run methods" do
    expect(@client).to respond_to(:run)
  end

  context "#run" do
    it "returns instance of OSS::Response when request succeed" do
      stub_request(:get, @endpoint).to_return(status: 200)
      expect(@client.run :get, '/').to be_instance_of(OSS::Response)
    end
  end

  context "#sign" do
    before do
      allow(@client.config).to receive(:access_key_secret) { "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV" }
    end

    it "returns the right signature" do
      string_to_sign = "PUT\nODBGOERFMDMzQTczRUY3NUE3NzA5QzdFNUYzMDQxNEM=\n" \
                       "text/html\nThu, 17 Nov 2005 18:49:58 GMT\n" \
                       "x-oss-magic:abracadabra\nx-oss-meta-author:foo" \
                       "@bar.com\n/oss-example/nelson"
      expect(@client.send :sign, string_to_sign).to eq("26NBxoKdsyly4EDv6inkoDft/yA=")
    end
  end

  context "#authorization_string" do
    before do
      allow(@client.options).to receive(:[]).with(:resource) { "/oss-example/nelson" }
      allow(@client.options).to receive(:[]).with(:sub_resource) { nil }
      allow(@client.config).to receive(:access_key_id) { "44CF9590006BF252F707" }
      allow(@client.config).to receive(:access_key_secret) { "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV" }
    end

    it "returns with authorization_string" do
      headers = {
        'Content-MD5' => 'ODBGOERFMDMzQTczRUY3NUE3NzA5QzdFNUYzMDQxNEM=',
        'Content-Type' => 'text/html',
        'Date' => 'Thu, 17 Nov 2005 18:49:58 GMT',
        'x-oss-magic' => 'abracadabra',
        'x-oss-meta-author' => 'foo@bar.com'
      }
      expect(@client.send :authorization_string, :put, headers).to eq("OSS 44CF9590006BF252F707:26NBxoKdsyly4EDv6inkoDft/yA=")
    end
  end

  context "#connection" do
    it "returns a instance of Faraday::Connection" do
      expect(@client.send :connection).to be_instance_of(Faraday::Connection)
    end
  end
end
