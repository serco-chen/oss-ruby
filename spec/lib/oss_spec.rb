require 'spec_helper'

describe OSS do
  it "instantiate an instance" do
    oss = OSS.new({
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      access_key_id: 'ACCESS_KEY_ID',
      access_key_secret: 'ACCESS_KEY_SECRET'
    })
    expect(oss).to be_an_instance_of(OSS::Base)
    expect(oss).to respond_to(:config)
  end
end
