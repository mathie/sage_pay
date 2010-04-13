require 'spec_helper'

include SagePay::Server
describe SignatureVerificationDetails do
  before(:each) do
    transaction_registration          = mock("Transaction registration", :vendor_tx_code => "vendor transaction id", :vendor => "vendor")
    transaction_registration_response = mock("Transaction registration response", :vps_tx_id => "sage pay transaction id", :security_key => "security key")
    @sig_details = SignatureVerificationDetails.new(transaction_registration, transaction_registration_response)
  end

  it "should take the vendor_tx_code from the transaction registration" do
    @sig_details.vendor_tx_code.should == "vendor transaction id"
  end

  it "should take the vendor from the transaction registration" do
    @sig_details.vendor.should == "vendor"
  end

  it "should take the vps_tx_id from the transaction registration response" do
    @sig_details.vps_tx_id.should == "sage pay transaction id"
  end

  it "should take the security_key from the transaction registration response" do
    @sig_details.security_key.should == "security key"
  end
end
