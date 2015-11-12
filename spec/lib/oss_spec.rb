require 'spec_helper'

describe OSS do
  it "should return data for a named element" do
    oss = OSS.new({
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      access_key_id: ENV['ACCESS_KEY_ID'],
      access_key_secret: ENV['ACCESS_KEY_SECRET']
    })
    expect(oss.instance_of? OSS::Base).to eq(true)
  end
end
