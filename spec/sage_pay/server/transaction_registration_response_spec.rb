require 'spec_helper'

include SagePay::Server

describe TransactionRegistrationResponse do
  it "should work straight from the factory" do
    lambda {
      transaction_registration_response_factory.should_not be_nil
    }.should_not raise_error
  end

  describe ".from_response_body" do
    context "with an invalid response" do
      before(:each) do
        @response_body = <<-RESPONSE
VPSProtocol=2.23
Status=INVALID
StatusDetail=4000 : The VendorName is invalid or the account is not active.
        RESPONSE
        @response = TransactionRegistrationResponse.from_response_body(@response_body)
      end

      it "should successfully parse the body" do
        lambda {
          TransactionRegistrationResponse.from_response_body(@response_body)
        }.should_not raise_error
      end

      it "should report the vps_protocol as '2.23'" do
        @response.vps_protocol.should == "2.23"
      end

      it "should report the status as :invalid" do
        @response.status.should == :invalid
      end

      it "should report the status detail as the status detail message supplied" do
        @response.status_detail.should == "4000 : The VendorName is invalid or the account is not active."
      end

      it "should admit to being invalid" do
        @response.should be_invalid
      end

      it "should admit to having failed" do
        @response.should be_failed
      end

      it "should raise an error if we try to ask for the transaction id" do
        lambda {
          @response.transaction_id
        }.should raise_error RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
      end

      it "should raise an error if we try to ask for the security key" do
        lambda {
          @response.security_key
        }.should raise_error RuntimeError, "Unable to retrieve the security key as the status was not OK."
      end

      it "should raise an error if we try to ask for the next URL" do
        lambda {
          @response.next_url
        }.should raise_error RuntimeError, "Unable to retrieve the next URL as the status was not OK."
      end
    end

    context "with a malformed response" do
      before(:each) do
        @response_body = <<-RESPONSE
VPSProtocol=2.23
Status=MALFORMED
StatusDetail=5000 : Your request had too many toes.
        RESPONSE
        @response = TransactionRegistrationResponse.from_response_body(@response_body)
      end

      it "should successfully parse the body" do
        lambda {
          TransactionRegistrationResponse.from_response_body(@response_body)
        }.should_not raise_error
      end

      it "should report the vps_protocol as '2.23'" do
        @response.vps_protocol.should == "2.23"
      end

      it "should report the status as :malformed" do
        @response.status.should == :malformed
      end

      it "should report the status detail as the status detail message supplied" do
        @response.status_detail.should == "5000 : Your request had too many toes."
      end

      it "should admit to being malformed" do
        @response.should be_malformed
      end

      it "should admit to having failed" do
        @response.should be_failed
      end

      it "should raise an error if we try to ask for the transaction id" do
        lambda {
          @response.transaction_id
        }.should raise_error RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
      end

      it "should raise an error if we try to ask for the security key" do
        lambda {
          @response.security_key
        }.should raise_error RuntimeError, "Unable to retrieve the security key as the status was not OK."
      end

      it "should raise an error if we try to ask for the next URL" do
        lambda {
          @response.next_url
        }.should raise_error RuntimeError, "Unable to retrieve the next URL as the status was not OK."
      end
    end

    context "with an error response" do
      before(:each) do
        @response_body = <<-RESPONSE
VPSProtocol=2.23
Status=ERROR
StatusDetail=5000 : SagePay blew up.
        RESPONSE
        @response = TransactionRegistrationResponse.from_response_body(@response_body)
      end

      it "should successfully parse the body" do
        lambda {
          TransactionRegistrationResponse.from_response_body(@response_body)
        }.should_not raise_error
      end

      it "should report the vps_protocol as '2.23'" do
        @response.vps_protocol.should == "2.23"
      end

      it "should report the status as :error" do
        @response.status.should == :error
      end

      it "should report the status detail as the status detail message supplied" do
        @response.status_detail.should == "5000 : SagePay blew up."
      end

      it "should admit to being an error" do
        @response.should be_error
      end

      it "should admit to having failed" do
        @response.should be_failed
      end

      it "should raise an error if we try to ask for the transaction id" do
        lambda {
          @response.transaction_id
        }.should raise_error RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
      end

      it "should raise an error if we try to ask for the security key" do
        lambda {
          @response.security_key
        }.should raise_error RuntimeError, "Unable to retrieve the security key as the status was not OK."
      end

      it "should raise an error if we try to ask for the next URL" do
        lambda {
          @response.next_url
        }.should raise_error RuntimeError, "Unable to retrieve the next URL as the status was not OK."
      end
    end

    context "with a valid response" do
      before(:each) do
        @response_body = <<-RESPONSE
VPSProtocol=2.23
Status=OK
StatusDetail=Server transaction registered successfully.
VPSTxId={728A5721-B45F-4570-937E-90A16B0A5000}
SecurityKey=17F13DCBD8
NextURL=https://test.sagepay.com/Simulator/VSPServerPaymentPage.asp?TransactionID={728A5721-B45F-4570-937E-90A16B0A5000}
        RESPONSE

        @response = TransactionRegistrationResponse.from_response_body(@response_body)
      end

      it "should successfully parse the body" do
        lambda {
          TransactionRegistrationResponse.from_response_body(@response_body)
        }.should_not raise_error
      end

      it "should report the vps_protocol as '2.23'" do
        @response.vps_protocol.should == "2.23"
      end

      it "should report the status as :OK" do
        @response.status.should == :ok
      end

      it "should admit to being OK" do
        @response.should be_ok
      end

      it "should not admit to being failed" do
        @response.should_not be_failed
      end

      it "should report the status detail as the status detail message supplied" do
        @response.status_detail.should == "Server transaction registered successfully."
      end

      it "should report the transaction id" do
        @response.transaction_id.should == "{728A5721-B45F-4570-937E-90A16B0A5000}"
      end

      it "should report the security key" do
        @response.security_key.should == "17F13DCBD8"
      end

      it "should report the next URL" do
        @response.next_url.should == "https://test.sagepay.com/Simulator/VSPServerPaymentPage.asp?TransactionID={728A5721-B45F-4570-937E-90A16B0A5000}"
      end
    end
  end
end
