require 'spec_helper'

if run_integration_specs?
  describe SagePay::Server, "integration specs" do
    describe ".payment" do
      before(:each) do
        SagePay::Server.default_registration_options = {
          :mode => :simulator,
          :vendor => "rubaidh",
          :notification_url => "http://test.host/notification"
        }

        @payment = SagePay::Server.payment(
          :description => "Demo payment",
          :amount => 12.34,
          :currency => "GBP",
          :billing_address => address_factory
        )
      end

      after(:each) do
        SagePay::Server.default_registration_options = {}
      end

      it "should successfully register the payment with SagePay" do
        @payment.register!.should_not be_nil
      end

      it "the registered payment should be OK" do
        registration = @payment.register!
        registration.should be_ok
      end

      it "should allow us to retrieve signature verification details" do
        @payment.register!
        sig_details = @payment.signature_verification_details

        sig_details.should_not                be_nil
        sig_details.vps_tx_id.should_not      be_nil
        sig_details.security_key.should_not   be_nil
        sig_details.vendor.should_not         be_nil
        sig_details.vendor_tx_code.should_not be_nil
      end
    end
  end
end
