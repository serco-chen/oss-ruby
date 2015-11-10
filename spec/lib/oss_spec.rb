require 'spec_helper'

describe OSS do
  it "should return data for a named element" do
    oss = OSS.new
    oss.list_all.should be_nil
    oss.symbol.should == 'O'
  end
end
