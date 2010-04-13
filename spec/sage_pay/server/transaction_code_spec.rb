require 'spec_helper'

include SagePay::Server

describe TransactionCode do
  it "should generate a transaction code" do
    TransactionCode.random.should_not be_nil
  end

  it "should not deliver two the same in a row" do
    first  = TransactionCode.random
    second = TransactionCode.random
    first.should_not == second
  end
end
