require 'spec_helper'

describe OSS::Config do
  before do
    @oss = OSS.new({
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      access_key_id: 'ACCESS_KEY_ID',
      access_key_secret: 'ACCESS_KEY_SECRET'
    })
  end

  it "has methods of endpoint, access_key_id, access_key_secret" do
    expect(@oss.config).to respond_to(:endpoint)
    expect(@oss.config).to respond_to(:access_key_id)
    expect(@oss.config).to respond_to(:access_key_secret)
  end

  it "use the configuration passed by options" do
    expect(@oss.config.endpoint).to eq('oss-cn-hangzhou.aliyuncs.com')
    expect(@oss.config.access_key_id).to eq('ACCESS_KEY_ID')
    expect(@oss.config.access_key_secret).to eq('ACCESS_KEY_SECRET')
  end
end
