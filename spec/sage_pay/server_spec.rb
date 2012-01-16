require 'spec_helper'

describe SagePay::Server do
  describe ".payment" do
    before(:each) do

      SagePay::Server.default_registration_options = {
        :mode => :test,
        :vendor => TEST_VENDOR_NAME,
        :notification_url => TEST_NOTIFICATION_URL
      }
    end

    after(:each) do
      SagePay::Server.default_registration_options = {}
    end

    it "should pass in the default registration options" do

      payment = SagePay::Server.payment
      payment.mode.should             == :test
      payment.vendor.should           == TEST_VENDOR_NAME
      payment.notification_url.should == TEST_NOTIFICATION_URL
    end

    it "should generate a vendor transaction code automatically" do
      payment = SagePay::Server.payment
      payment.vendor_tx_code.should_not be_nil
    end

    it "should set the transaction type to :payment" do
      payment = SagePay::Server.payment
      payment.tx_type.should == :payment
    end

    it "should duplicate the billing address to the delivery address if no billing address is supplied" do
      address = mock("Home address")

      payment = SagePay::Server.payment :billing_address => address
      payment.delivery_address.should == address
    end

    it "should not overwrite a delivery address if one is supplied" do
      billing_address = mock("Billing address")
      delivery_address = mock("Delivery address")

      payment = SagePay::Server.payment :billing_address => billing_address, :delivery_address => delivery_address
      payment.delivery_address.should == delivery_address
      payment.billing_address.should  == billing_address
    end

    it "should allow the caller to override any of the default registration options" do
      payment = SagePay::Server.payment :vendor => "chickens"
      payment.vendor.should == "chickens"
    end

    it "should allow the caller to override any of the calculated default registration options (eg vendor tx code)" do
      payment = SagePay::Server.payment :vendor_tx_code => "chickens"
      payment.vendor_tx_code.should == "chickens"
    end

    it "should generate a valid payment given the minimum set of fields" do
      address = address_factory
      payment = SagePay::Server.payment(
        :description => "Demo payment",
        :amount => 12.34,
        :currency => "GBP",
        :billing_address => address
      )
      payment.should be_valid
    end
  end
end
