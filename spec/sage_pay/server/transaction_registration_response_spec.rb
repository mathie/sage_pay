require 'spec_helper'

describe SagePay::Server::TransactionRegistrationResponse do
  it "should work straight from the factory" do
    lambda {
      transaction_registration_response_factory.should be_valid
    }.should_not raise_error
  end
end
