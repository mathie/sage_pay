require 'spec_helper'

include SagePay::Server

describe Notification do
  it "should work straight from the factory" do
    lambda {
      notification_factory.should_not be_nil
    }.should_not raise_error
  end

  describe ".from_params" do
    before(:each) do
      @params = {
        "VPSProtocol"    => "2.23",
        "TxType"         => "PAYMENT",
        "VendorTxCode"   => "unique-tx-code",
        "VPSTxId"        => "{728A5721-B45F-4570-937E-90A16B0A5000}",
        "Status"         => "OK",
        "StatusDetail"   => "2000 : Card processed successfully.", # FIXME: Make this match reality
        "TxAuthNo"       => "1234567890",
        "AVSCV2"         => "ALL MATCH",
        "AddressResult"  => "MATCHED",
        "PostCodeResult" => "MATCHED",
        "CV2Result"      => "MATCHED",
        "GiftAid"        => "0",
        "3DSecureStatus" => "OK",
        "CAVV"           => "Something?",
        "AddressStatus"  => "CONFIRMED",
        "PayerStatus"    => "VERIFIED",
        "CardType"       => "VISA",
        "Last4Digits"    => "1234",
        # FIXME: Calculated manually using the information above. Should
        # really get one from a sample transaction...
        "VPSSignature"   => "6AB7A7FFB5369AF953CD57A84D5C2979"
      }
    end

    context "with an OK status" do
      before(:each) do
        signature_verification_details = mock("Signature verification details",
          :vendor         => "rubaidh",
          :security_key   => "17F13DCBD8"
        )

        @notification = Notification.from_params(@params, signature_verification_details)
      end

      it "should successfully parse the params" do
        lambda {
          Notification.from_params(@params).should_not be_nil
        }.should_not raise_error
      end

      it "should report the vps_protocol as '2.23'" do
        @notification.vps_protocol.should == "2.23"
      end

      it "should report the tx_type as :payment" do
        @notification.tx_type.should == :payment
      end

      it "should report the vendor_tx_code as the vendor tx code supplied" do
        @notification.vendor_tx_code.should == 'unique-tx-code'
      end

      it "should report the vps_tx_id as the vps_tx_id supplied" do
        @notification.vps_tx_id.should == "{728A5721-B45F-4570-937E-90A16B0A5000}"
      end

      it "should report the status as :ok" do
        @notification.status.should == :ok
      end

      it "should be ok" do
        @notification.should be_ok
      end

      it "should report the status detail as the status detail message supplied" do
        @notification.status_detail.should == "2000 : Card processed successfully."
      end

      it "should report the transaction authorisation number as a string (even if the spec says it's always an integer I'm betting leading zeros are important)" do
        @notification.tx_auth_no.should == "1234567890"
      end

      it "should report the avs_cv2 as :all_match" do
        @notification.avs_cv2.should == :all_match
      end

      it "should report the avs_cv2? as true" do
        @notification.should be_avs_cv2_matched
      end

      it "should report the address result as :matched" do
        @notification.address_result.should == :matched
      end

      it "should report the address as matched" do
        @notification.should be_address_matched
      end

      it "should report the post code result as :matched" do
        @notification.post_code_result.should == :matched
      end

      it "should report the post code as matched" do
        @notification.should be_post_code_matched
      end

      it "should report the CV2 result as :matched" do
        @notification.cv2_result.should == :matched
      end

      it "should report the cv2 as matched" do
        @notification.should be_cv2_matched
      end

      it "should report gift aid as false" do
        @notification.gift_aid.should be_false
      end

      it "should report the 3d secure status as :ok" do
        @notification.threed_secure_status.should == :ok
      end

      it "should report the 3d secure status as ok" do
        @notification.should be_threed_secure_status_ok
      end

      it "should report the value passed in for the CAVV result" do
        @notification.cavv.should == "Something?"
      end

      it "should report the address status as confirmed" do
        @notification.address_status.should == :confirmed
      end

      it "should report the payer status as verified" do
        @notification.payer_status.should == :verified
      end

      it "should report the card type as visa" do
        @notification.card_type.should == :visa
      end

      it "should report the last 4 digits as 1234" do
        @notification.last_4_digits.should == "1234"
      end

      it "should report that the vps signature is valid" do
        @notification.should be_valid_signature
      end

      it "should generate a successful response" do
        mock_notification_response = mock(NotificationResponse, :response => "some response")
        NotificationResponse.should_receive(:new).with(:status => :ok, :redirect_url => "mock redirect url").and_return(mock_notification_response)
        @notification.response("mock redirect url").should == "some response"
      end
    end

    context "with an invalid signature" do
      before(:each) do
        signature_verification_details = mock("Signature verification details",
          :vendor         => "rubaidh",
          :security_key   => "different security key"
        )

        @notification = Notification.from_params(@params, signature_verification_details)
      end

      it "should generate a failed response" do
        mock_notification_response = mock(NotificationResponse, :response => "can haz failure")
        NotificationResponse.should_receive(:new).with(:status => :invalid, :redirect_url => "mock redirect url", :status_detail => "Signature did not match our expectations").and_return(mock_notification_response)
        @notification.response("mock redirect url").should == "can haz failure"
      end
    end

    context "with a block supplied for the signature verification details" do
      it "should still validate the signature correctly" do
        notification = Notification.from_params(@params) do |attributes|
          mock("Signature verification details",
            :vendor         => "rubaidh",
            :security_key   => "17F13DCBD8"
          )
        end

        notification.should be_valid_signature
      end
    end
  end
end
