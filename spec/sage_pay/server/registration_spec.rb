require 'spec_helper'

include SagePay::Server

describe Registration do

  it "should work straight from the factory" do
    lambda {
      registration_factory.should be_valid
    }.should_not raise_error
  end

  it "should report protocol version 2.23" do
    registration = Registration.new
    registration.vps_protocol.should == "2.23"
  end

  describe "conversions" do
    it "should accept a float for the amount and convert it to a BigDecimal interally" do
      registration = registration_factory(:amount => 12.34)
      registration.should be_valid
      registration.amount.should == BigDecimal.new("12.34")
    end

    it "should accept an integer for the amount and convert it to a BigDecimal interally" do
      registration = registration_factory(:amount => 12)
      registration.should be_valid
      registration.amount.should == BigDecimal.new("12")
    end

    it "should accept a string for the amount and convert it to a BigDecimal interally" do
      registration = registration_factory(:amount => "12")
      registration.should be_valid
      registration.amount.should == BigDecimal.new("12")
    end
  end

  describe "validations" do
    should_validate_presence_of(:mode)
    should_validate_presence_of(:tx_type)
    should_validate_presence_of(:vendor)
    should_validate_presence_of(:vendor_tx_code)
    should_validate_presence_of(:amount)
    should_validate_presence_of(:currency)
    should_validate_presence_of(:description)
    should_validate_presence_of(:notification_url)
    should_validate_presence_of(:billing_address)
    should_validate_presence_of(:delivery_address)

    should_not_validate_presence_of(:customer_email)
    should_not_validate_presence_of(:basket)
    should_not_validate_presence_of(:allow_gift_aid)
    should_not_validate_presence_of(:apply_avs_cv2)
    should_not_validate_presence_of(:apply_3d_secure)
    should_not_validate_presence_of(:profile)
    should_not_validate_presence_of(:billing_agreement)
    should_not_validate_presence_of(:account_type)

    should_validate_length_of(:vendor, :maximum => 15)
    should_validate_length_of(:vendor_tx_code, :maximum => 40)
    should_validate_length_of(:currency, :exactly => 3)
    should_validate_length_of(:description, :maximum => 100)
    should_validate_length_of(:notification_url, :maximum => 255)
    should_validate_length_of(:notification_url, :maximum => 255)
    should_validate_length_of(:customer_email, :maximum => 255)
    should_validate_length_of(:basket, :maximum => 7500)

    it "should allow the amount to be a minimum of 0.01" do
      registration = registration_factory(:amount => "0.01")
      registration.should be_valid

      registration = registration_factory(:amount => "0.00")
      registration.should_not be_valid
      registration.errors[:amount].should include("is less than the minimum value (0.01)")

      registration = registration_factory(:amount => "-23")
      registration.should_not be_valid
      registration.errors[:amount].should include("is less than the minimum value (0.01)")
    end

    it "should allow the amount to be a maximum of 100,000.00" do
      registration = registration_factory(:amount => "100000")
      registration.should be_valid

      registration = registration_factory(:amount => "100000.01")
      registration.should_not be_valid
      registration.errors[:amount].should include("is greater than the maximum value (100,000.00)")

      registration = registration_factory(:amount => "123456")
      registration.should_not be_valid
      registration.errors[:amount].should include("is greater than the maximum value (100,000.00)")
    end

    it "should allow the transaction type to be one of :payment, :deferred or :authenticate" do
      registration = registration_factory(:tx_type => :payment)
      registration.should be_valid

      registration = registration_factory(:tx_type => :deferred)
      registration.should be_valid

      registration = registration_factory(:tx_type => :authenticate)
      registration.should be_valid

      registration = registration_factory(:tx_type => :chickens)
      registration.should_not be_valid
      registration.errors[:tx_type].should include("is not in the list")
    end

    it "should allow the mode to be one of :simulator, :test or :live" do
      registration = registration_factory(:mode => :simulator)
      registration.should be_valid

      registration = registration_factory(:mode => :test)
      registration.should be_valid

      registration = registration_factory(:mode => :live)
      registration.should be_valid

      registration = registration_factory(:mode => :chickens)
      registration.should_not be_valid
      registration.errors[:mode].should include("is not in the list")
    end

    it "should allow the gift aid setting to be true or false" do
      registration = registration_factory(:allow_gift_aid => true)
      registration.should be_valid

      registration = registration_factory(:allow_gift_aid => false)
      registration.should be_valid

      registration = registration_factory(:allow_gift_aid => "chickens")
      registration.should_not be_valid
      registration.errors[:allow_gift_aid].should include("is not in the list")
    end

    it "should allow apply_avs_cv2 to be 0 through 3 (see docs for what that means)" do
      registration = registration_factory(:apply_avs_cv2 => 0)
      registration.should be_valid

      registration = registration_factory(:apply_avs_cv2 => 1)
      registration.should be_valid

      registration = registration_factory(:apply_avs_cv2 => 2)
      registration.should be_valid

      registration = registration_factory(:apply_avs_cv2 => 3)
      registration.should be_valid

      registration = registration_factory(:apply_avs_cv2 => 4)
      registration.should_not be_valid
      registration.errors[:apply_avs_cv2].should include("is not in the list")
    end

    it "should allow apply_3d_secure to be 0 through 3 (see docs for what that means)" do
      registration = registration_factory(:apply_3d_secure => 0)
      registration.should be_valid

      registration = registration_factory(:apply_3d_secure => 1)
      registration.should be_valid

      registration = registration_factory(:apply_3d_secure => 2)
      registration.should be_valid

      registration = registration_factory(:apply_3d_secure => 3)
      registration.should be_valid

      registration = registration_factory(:apply_3d_secure => 4)
      registration.should_not be_valid
      registration.errors[:apply_3d_secure].should include("is not in the list")
    end

    it "should allow profile to be normal or low" do
      registration = registration_factory(:profile => :normal)
      registration.should be_valid

      registration = registration_factory(:profile => :low)
      registration.should be_valid

      registration = registration_factory(:profile => :chickens)
      registration.should_not be_valid
      registration.errors[:profile].should include("is not in the list")
    end

    it "should allow billing_agreement to be true or false" do
      registration = registration_factory(:billing_agreement => true)
      registration.should be_valid

      registration = registration_factory(:billing_agreement => false)
      registration.should be_valid

      registration = registration_factory(:billing_agreement => "chickens")
      registration.should_not be_valid
      registration.errors[:billing_agreement].should include("is not in the list")
    end

    it "should allow the account type to be one of ecommerce, continuous authority or mail order" do
      registration = registration_factory(:account_type => :ecommerce)
      registration.should be_valid

      registration = registration_factory(:account_type => :continuous_authority)
      registration.should be_valid

      registration = registration_factory(:account_type => :mail_order)
      registration.should be_valid

      registration = registration_factory(:account_type => :chickens)
      registration.should_not be_valid
      registration.errors[:account_type].should include("is not in the list")
    end
  end

  describe "url generation" do
    it "should pick the correct url for the simulator mode" do
      registration = registration_factory(:mode => :simulator)
      registration.url.should == "https://test.sagepay.com/simulator/VSPServerGateway.asp?Service=VendorRegisterTx"
    end

    it "should pick the correct url for the test mode" do
      registration = registration_factory(:mode => :test)
      registration.url.should == "https://test.sagepay.com/gateway/service/vspserver-register.vsp"
    end

    it "should pick the correct url for the live mode" do
      registration = registration_factory(:mode => :live)
      registration.url.should == "https://live.sagepay.com/gateway/service/vspserver-register.vsp"
    end

    it "should raise an error if the mode has been set to something dodgy" do
      lambda {
        registration = registration_factory(:mode => :dead_chickens)
        registration.url
      }.should raise_error(ArgumentError, "Invalid transaction mode")
    end
  end

  describe "post params generation" do
    context "given one or more invalid parameters" do
      it "should raise an error when trying to generate the URL" do
        registration = registration_factory(:tx_type => :invalid)
        lambda { registration.post_params }.should raise_error(ArgumentError, "Invalid transaction registration options (see errors hash for details)")
      end
    end

    context "given the minimum set of required parameters" do
      before(:each) do
        billing_address = address_factory(
          :first_names => "Billing First",
          :surname     => "Billing Surname",
          :address_1   => "Billing Address 1",
          :city        => "Billing City",
          :post_code   => "BI11 1NG",
          :country     => "GB"
        )

        delivery_address = address_factory(
          :first_names => "Delivery First",
          :surname     => "Delivery Surname",
          :address_1   => "Delivery Address 1",
          :city        => "Delivery City",
          :post_code   => "DE11 3RY",
          :country     => "GB"
        )

        @registration = registration_factory(
          :mode             => :simulator,
          :tx_type          => :payment,
          :vendor           => "vendorname",
          :vendor_tx_code   => "unique-tx-code",
          :amount           => 57.93,
          :currency         => "GBP",
          :description      => "A sample transaction",
          :notification_url => "http://test.host/sample/notification",
          :billing_address  => billing_address,
          :delivery_address => delivery_address
        )
      end

      describe "the posted params" do
        it "should contain the transaction type" do
          @registration.post_params["TxType"].should == "PAYMENT"
        end

        it "should contain the vendor" do
          @registration.post_params["Vendor"].should == "vendorname"
        end

        it "should contain the vendor tx code" do
          @registration.post_params["VendorTxCode"].should == "unique-tx-code"
        end

        it "should contain the amount" do
          @registration.post_params["Amount"].should == "57.93"
        end

        it "should contain the currency" do
          @registration.post_params["Currency"].should == "GBP"
        end

        it "should contain the description" do
          @registration.post_params["Description"].should == "A sample transaction"
        end

        it "should contain the notification URL" do
          @registration.post_params["NotificationURL"].should == "http://test.host/sample/notification"
        end

        it "should contain the billing surname" do
          @registration.post_params["BillingSurname"].should == "Billing Surname"
        end

        it "should contain the billing first names" do
          @registration.post_params["BillingFirstnames"].should == "Billing First"
        end

        it "should contain the billing address 1" do
          @registration.post_params["BillingAddress1"].should == "Billing Address 1"
        end

        it "should contain the billing city" do
          @registration.post_params["BillingCity"].should == "Billing City"
        end

        it "should contain the billing post code" do
          @registration.post_params["BillingPostCode"].should == "BI11 1NG"
        end

        it "should contain the billing country" do
          @registration.post_params["BillingCountry"].should == "GB"
        end

        it "should contain the delivery surname" do
          @registration.post_params["DeliverySurname"].should == "Delivery Surname"
        end

        it "should contain the delivery first names" do
          @registration.post_params["DeliveryFirstnames"].should == "Delivery First"
        end

        it "should contain the delivery address 1" do
          @registration.post_params["DeliveryAddress1"].should == "Delivery Address 1"
        end

        it "should contain the delivery city" do
          @registration.post_params["DeliveryCity"].should == "Delivery City"
        end

        it "should contain the delivery post code" do
          @registration.post_params["DeliveryPostCode"].should == "DE11 3RY"
        end

        it "should contain the delivery country" do
          @registration.post_params["DeliveryCountry"].should == "GB"
        end
      end

      context "with each of the optional parameters" do
        it "should contain the billing address 2 only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('BillingAddress2')

          registration.billing_address.address_2 = "Some Area"
          registration.post_params['BillingAddress2'].should == "Some Area"
        end

        it "should contain the billing state only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('BillingState')

          registration.billing_address.state = "KY"
          registration.post_params['BillingState'].should == "KY"
        end

        it "should contain the billing phone only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('BillingPhone')

          registration.billing_address.phone = "0123456789"
          registration.post_params['BillingPhone'].should == "0123456789"
        end

        it "should contain the delivery address 2 only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('DeliveryAddress2')

          registration.delivery_address.address_2 = "Some Area"
          registration.post_params['DeliveryAddress2'].should == "Some Area"
        end

        it "should contain the delivery state only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('DeliveryState')

          registration.delivery_address.state = "KY"
          registration.post_params['DeliveryState'].should == "KY"
        end

        it "should contain the delivery phone only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('DeliveryPhone')

          registration.delivery_address.phone = "0123456789"
          registration.post_params['DeliveryPhone'].should == "0123456789"
        end

        it "should contain the customer email only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('CustomerEmail')

          registration.customer_email = "jimbob@example.com"
          registration.post_params['CustomerEmail'].should == "jimbob@example.com"
        end

        it "should contain the basket only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('Basket')

          registration.basket = "Sample basket"
          registration.post_params['Basket'].should == "Sample basket"
        end

        it "should contain allow_gift_aid only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('AllowGiftAid')

          registration.allow_gift_aid = true
          registration.post_params['AllowGiftAid'].should == "1"

          registration.allow_gift_aid = false
          registration.post_params['AllowGiftAid'].should == "0"
        end

        it "should contain apply_avs_cv2 only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('ApplyAVSCV2')

          registration.apply_avs_cv2 = 0
          registration.post_params['ApplyAVSCV2'].should == "0"

          registration.apply_avs_cv2 = 1
          registration.post_params['ApplyAVSCV2'].should == "1"

          registration.apply_avs_cv2 = 2
          registration.post_params['ApplyAVSCV2'].should == "2"

          registration.apply_avs_cv2 = 3
          registration.post_params['ApplyAVSCV2'].should == "3"
        end

        it "should contain apply_3d_secure only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('ApplyAVSCV2')

          registration.apply_3d_secure = 0
          registration.post_params['Apply3DSecure'].should == "0"

          registration.apply_3d_secure = 1
          registration.post_params['Apply3DSecure'].should == "1"

          registration.apply_3d_secure = 2
          registration.post_params['Apply3DSecure'].should == "2"

          registration.apply_3d_secure = 3
          registration.post_params['Apply3DSecure'].should == "3"
        end

        it "should contain profile only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('Profile')

          registration.profile = :normal
          registration.post_params['Profile'].should == "NORMAL"

          registration.profile = :low
          registration.post_params['Profile'].should == "LOW"
        end

        it "should contain billing_agreement only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('BillingAgreement')

          registration.billing_agreement = true
          registration.post_params['BillingAgreement'].should == "1"

          registration.billing_agreement = false
          registration.post_params['BillingAgreement'].should == "0"
        end

        it "should contain account type only if supplied" do
          registration = registration_factory
          registration.post_params.keys.should_not include('AccountType')

          registration.account_type = :ecommerce
          registration.post_params['AccountType'].should == "E"

          registration.account_type = :continuous_authority
          registration.post_params['AccountType'].should == "C"

          registration.account_type = :mail_order
          registration.post_params['AccountType'].should == "M"
        end
      end
    end
  end

  describe "#run!" do
    context "if SagePay is having a bad day" do
      before(:each) do
        @registration = registration_factory
        @registration.stub(:post).and_return(mock("HTTP Response", :code => "500"))
      end

      it "should raise an exception to say that we couldn't talk to SagePay" do
        lambda {
          @registration.run!
        }.should raise_error RuntimeError, "I guess SagePay doesn't like us today." # almost, because now its custom message
      end
    end

    context "when SagePay can return a useful response" do
      before(:each) do
        @mock_http_response = mock("HTTP response", :code => "200", :body => "mock response body")
        @mock_response = mock("Transaction registration response")
        @registration = registration_factory
        @registration.stub(:post).and_return(@mock_http_response)
        RegistrationResponse.stub(:from_response_body).and_return @mock_response
      end

      it "should return a newly created RegistrationResponse with the response" do
        response = @registration.run!
        response.should == @mock_response
      end

      it "should pass the response body to RegistrationResponse.from_response_body to let it parse and initialize" do
        RegistrationResponse.should_receive(:from_response_body).with("mock response body")
        @registration.run!
      end

      it "should post the request to SagePay" do
        @registration.should_receive(:post)
        @registration.run!
      end

      it "should not allow us to attempt to register twice with the same vendor transaction code" do
        @registration.run!
        lambda {
          @registration.run!
        }.should raise_error(RuntimeError, "This vendor transaction code has already been registered")
      end

      it "should allow us to register twice if we change the vendor transaction code in between times" do
        @registration.run!
        lambda {
          @registration.vendor_tx_code = TransactionCode.random
          @registration.run!.should == @mock_response
        }.should_not raise_error(RuntimeError, "This vendor transaction code has already been registered")
      end
    end
  end

  describe "#signature_verification_details" do
    before(:each) do
      mock_response = mock("Transaction registration response", :vps_tx_id => "sage pay transaction id", :security_key => 'security key')

      @registration = registration_factory :vendor_tx_code => "vendor transaction id", :vendor => "vendor"
      @registration.stub(:handle_response).and_return(mock_response)
      @registration.stub(:post)
    end

    context "before registering a transaction" do
      it "should raise an error" do
        lambda {
          @registration.signature_verification_details
        }.should raise_error(RuntimeError, "Not yet registered")
      end
    end

    context "with a transaction which failed" do
      before(:each) do
        mock_response = mock("Transaction registration response", :failed? => true)
        @registration.stub(:handle_response).and_return(mock_response)
        @registration.run!
      end

      it "should raise an error" do
        lambda {
          @registration.signature_verification_details
        }.should raise_error(RuntimeError, "Registration failed")
      end
    end

    context "with a good transaction" do
      before(:each) do
        mock_response = mock("Transaction registration response", :failed? => false, :vps_tx_id => "sage pay transaction id", :security_key => 'security key')
        @registration.stub(:handle_response).and_return(mock_response)
        @registration.run!
      end

      it "should know the vendor" do
        sig_details = @registration.signature_verification_details
        sig_details.vendor.should == "vendor"
      end

      it "should know the security key" do
        sig_details = @registration.signature_verification_details
        sig_details.security_key.should == "security key"
      end
    end
  end
end
