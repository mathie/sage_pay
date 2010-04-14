require 'spec_helper'

include SagePay::Server
describe SignatureVerificationDetails do
  before(:each) do
    transaction_registration          = mock("Transaction registration", :vendor => "vendor")
    transaction_registration_response = mock("Transaction registration response", :security_key => "security key")
    @sig_details = SignatureVerificationDetails.new(transaction_registration, transaction_registration_response)
  end

  it "should take the vendor from the transaction registration" do
    @sig_details.vendor.should == "vendor"
  end

  it "should take the security_key from the transaction registration response" do
    @sig_details.security_key.should == "security key"
  end
end
