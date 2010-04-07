require 'spec_helper'

describe SagePay::Server::TransactionRegistration do
  it "should report protocol version 2.23" do
    transaction_registration = SagePay::Server::TransactionRegistration.new
    transaction_registration.vps_protocol.should == "2.23"
  end
end
