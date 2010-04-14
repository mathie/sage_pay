require 'spec_helper'

include SagePay::Server
describe SignatureVerificationDetails do
  before(:each) do
    @sig_details = SignatureVerificationDetails.new("vendor", "security key")
  end

  it "should take the vendor from the transaction registration" do
    @sig_details.vendor.should == "vendor"
  end

  it "should take the security_key from the transaction registration response" do
    @sig_details.security_key.should == "security key"
  end
end
