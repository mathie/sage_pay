require 'spec_helper'

include SagePay::Server

describe TransactionRegistration do

  it "should work straight from the factory" do
    lambda {
      transaction_registration_factory.should be_valid
    }.should_not raise_error
  end

  it "should report protocol version 2.23" do
    transaction_registration = TransactionRegistration.new
    transaction_registration.vps_protocol.should == "2.23"
  end

  describe "conversions" do
    it "should accept a float for the amount and convert it to a BigDecimal interally" do
      transaction_registration = transaction_registration_factory(:amount => 12.34)
      transaction_registration.should be_valid
      transaction_registration.amount.should == BigDecimal.new("12.34")
    end

    it "should accept an integer for the amount and convert it to a BigDecimal interally" do
      transaction_registration = transaction_registration_factory(:amount => 12)
      transaction_registration.should be_valid
      transaction_registration.amount.should == BigDecimal.new("12")
    end

    it "should accept a string for the amount and convert it to a BigDecimal interally" do
      transaction_registration = transaction_registration_factory(:amount => "12")
      transaction_registration.should be_valid
      transaction_registration.amount.should == BigDecimal.new("12")
    end
  end

  describe "validations" do
    it { validates_the_presence_of(:transaction_registration, :mode)             }
    it { validates_the_presence_of(:transaction_registration, :tx_type)          }
    it { validates_the_presence_of(:transaction_registration, :vendor)           }
    it { validates_the_presence_of(:transaction_registration, :vendor_tx_code)   }
    it { validates_the_presence_of(:transaction_registration, :amount)           }
    it { validates_the_presence_of(:transaction_registration, :currency)         }
    it { validates_the_presence_of(:transaction_registration, :description)      }
    it { validates_the_presence_of(:transaction_registration, :notification_url) }
    it { validates_the_presence_of(:transaction_registration, :billing_address)  }
    it { validates_the_presence_of(:transaction_registration, :delivery_address) }

    it { does_not_require_the_presence_of(:transaction_registration, :customer_email)    }
    it { does_not_require_the_presence_of(:transaction_registration, :basket)            }
    it { does_not_require_the_presence_of(:transaction_registration, :allow_gift_aid)    }
    it { does_not_require_the_presence_of(:transaction_registration, :apply_avs_cv2)     }
    it { does_not_require_the_presence_of(:transaction_registration, :apply_3d_secure)   }
    it { does_not_require_the_presence_of(:transaction_registration, :profile)           }
    it { does_not_require_the_presence_of(:transaction_registration, :billing_agreement) }
    it { does_not_require_the_presence_of(:transaction_registration, :account_type)      }

    it { validates_the_length_of(:transaction_registration, :vendor,           :max => 15)    }
    it { validates_the_length_of(:transaction_registration, :vendor_tx_code,   :max => 40)    }
    it { validates_the_length_of(:transaction_registration, :currency,         :exactly => 3) }
    it { validates_the_length_of(:transaction_registration, :description,      :max => 100)   }
    it { validates_the_length_of(:transaction_registration, :notification_url, :max => 255)   }
    it { validates_the_length_of(:transaction_registration, :notification_url, :max => 255)   }
    it { validates_the_length_of(:transaction_registration, :customer_email,   :max => 255)   }
    it { validates_the_length_of(:transaction_registration, :basket,           :max => 7500)  }

    it "should allow the amount to be a minimum of 0.01" do
      transaction_registration = transaction_registration_factory(:amount => "0.01")
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:amount => "0.00")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:amount).should include("is less than the minimum value (0.01)")

      transaction_registration = transaction_registration_factory(:amount => "-23")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:amount).should include("is less than the minimum value (0.01)")
    end

    it "should allow the amount to be a maximum of 100,000.00" do
      transaction_registration = transaction_registration_factory(:amount => "100000")
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:amount => "100000.01")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:amount).should include("is greater than the maximum value (100,000.00)")

      transaction_registration = transaction_registration_factory(:amount => "123456")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:amount).should include("is greater than the maximum value (100,000.00)")
    end

    it "should allow the transaction type to be one of :payment, :deferred or :authenticate" do
      transaction_registration = transaction_registration_factory(:tx_type => :payment)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:tx_type => :deferred)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:tx_type => :authenticate)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:tx_type => :chickens)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:tx_type).should include("is not in the list")
    end

    it "should allow the mode to be one of :simulator, :test or :live" do
      transaction_registration = transaction_registration_factory(:mode => :simulator)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:mode => :test)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:mode => :live)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:mode => :chickens)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:mode).should include("is not in the list")
    end

    it "should allow the gift aid setting to be true or false" do
      transaction_registration = transaction_registration_factory(:allow_gift_aid => true)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:allow_gift_aid => false)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:allow_gift_aid => "chickens")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:allow_gift_aid).should include("is not in the list")
    end

    it "should allow apply_avs_cv2 to be 0 through 3 (see docs for what that means)" do
      transaction_registration = transaction_registration_factory(:apply_avs_cv2 => 0)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_avs_cv2 => 1)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_avs_cv2 => 2)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_avs_cv2 => 3)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_avs_cv2 => 4)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:apply_avs_cv2).should include("is not in the list")
    end

    it "should allow apply_3d_secure to be 0 through 3 (see docs for what that means)" do
      transaction_registration = transaction_registration_factory(:apply_3d_secure => 0)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_3d_secure => 1)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_3d_secure => 2)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_3d_secure => 3)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:apply_3d_secure => 4)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:apply_3d_secure).should include("is not in the list")
    end

    it "should allow profile to be normal or low" do
      transaction_registration = transaction_registration_factory(:profile => :normal)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:profile => :low)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:profile => :chickens)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:profile).should include("is not in the list")
    end

    it "should allow billing_agreement to be true or false" do
      transaction_registration = transaction_registration_factory(:billing_agreement => true)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:billing_agreement => false)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:billing_agreement => "chickens")
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:billing_agreement).should include("is not in the list")
    end

    it "should allow the account type to be one of ecommerce, continuous authority or mail order" do
      transaction_registration = transaction_registration_factory(:account_type => :ecommerce)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:account_type => :continuous_authority)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:account_type => :mail_order)
      transaction_registration.should be_valid

      transaction_registration = transaction_registration_factory(:account_type => :chickens)
      transaction_registration.should_not be_valid
      transaction_registration.errors.on(:account_type).should include("is not in the list")
    end
  end

  describe "url generation" do
    it "should pick the correct url for the simulator mode" do
      transaction_registration = transaction_registration_factory(:mode => :simulator)
      transaction_registration.url.should == "https://test.sagepay.com/simulator/VSPServerGateway.asp?Service=VendorRegisterTx"
    end

    it "should pick the correct url for the test mode" do
      transaction_registration = transaction_registration_factory(:mode => :test)
      transaction_registration.url.should == "https://test.sagepay.com/gateway/service/vspserver-register.vsp"
    end

    it "should pick the correct url for the live mode" do
      transaction_registration = transaction_registration_factory(:mode => :live)
      transaction_registration.url.should == "https://live.sagepay.com/gateway/service/vspserver-register.vsp"
    end

  end

  describe "post params generation" do
    context "given one or more invalid parameters" do
      it "should raise an error when trying to generate the URL" do
        transaction_registration = transaction_registration_factory(:tx_type => :invalid)
        lambda { transaction_registration.post_params }.should raise_error(ArgumentError, "Invalid transaction registration options (see errors hash for details)")
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

        @transaction_registration = transaction_registration_factory(
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
          @transaction_registration.post_params["TxType"].should == "PAYMENT"
        end

        it "should contain the vendor" do
          @transaction_registration.post_params["Vendor"].should == "vendorname"
        end

        it "should contain the vendor tx code" do
          @transaction_registration.post_params["VendorTxCode"].should == "unique-tx-code"
        end

        it "should contain the amount" do
          @transaction_registration.post_params["Amount"].should == "57.93"
        end

        it "should contain the currency" do
          @transaction_registration.post_params["Currency"].should == "GBP"
        end

        it "should contain the description" do
          @transaction_registration.post_params["Description"].should == "A sample transaction"
        end

        it "should contain the notification URL" do
          @transaction_registration.post_params["NotificationURL"].should == "http://test.host/sample/notification"
        end

        it "should contain the billing surname" do
          @transaction_registration.post_params["BillingSurname"].should == "Billing Surname"
        end

        it "should contain the billing first names" do
          @transaction_registration.post_params["BillingFirstnames"].should == "Billing First"
        end

        it "should contain the billing address 1" do
          @transaction_registration.post_params["BillingAddress1"].should == "Billing Address 1"
        end

        it "should contain the billing city" do
          @transaction_registration.post_params["BillingCity"].should == "Billing City"
        end

        it "should contain the billing post code" do
          @transaction_registration.post_params["BillingPostCode"].should == "BI11 1NG"
        end

        it "should contain the billing country" do
          @transaction_registration.post_params["BillingCountry"].should == "GB"
        end

        it "should contain the delivery surname" do
          @transaction_registration.post_params["DeliverySurname"].should == "Delivery Surname"
        end

        it "should contain the delivery first names" do
          @transaction_registration.post_params["DeliveryFirstnames"].should == "Delivery First"
        end

        it "should contain the delivery address 1" do
          @transaction_registration.post_params["DeliveryAddress1"].should == "Delivery Address 1"
        end

        it "should contain the delivery city" do
          @transaction_registration.post_params["DeliveryCity"].should == "Delivery City"
        end

        it "should contain the delivery post code" do
          @transaction_registration.post_params["DeliveryPostCode"].should == "DE11 3RY"
        end

        it "should contain the delivery country" do
          @transaction_registration.post_params["DeliveryCountry"].should == "GB"
        end
      end

      context "with each of the optional parameters" do
        it "should contain the billing address 2 only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('BillingAddress2')

          transaction_registration.billing_address.address_2 = "Some Area"
          transaction_registration.post_params['BillingAddress2'].should == "Some Area"
        end

        it "should contain the billing state only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('BillingState')

          transaction_registration.billing_address.state = "KY"
          transaction_registration.post_params['BillingState'].should == "KY"
        end

        it "should contain the billing phone only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('BillingPhone')

          transaction_registration.billing_address.phone = "0123456789"
          transaction_registration.post_params['BillingPhone'].should == "0123456789"
        end

        it "should contain the delivery address 2 only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('DeliveryAddress2')

          transaction_registration.delivery_address.address_2 = "Some Area"
          transaction_registration.post_params['DeliveryAddress2'].should == "Some Area"
        end

        it "should contain the delivery state only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('DeliveryState')

          transaction_registration.delivery_address.state = "KY"
          transaction_registration.post_params['DeliveryState'].should == "KY"
        end

        it "should contain the delivery phone only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('DeliveryPhone')

          transaction_registration.delivery_address.phone = "0123456789"
          transaction_registration.post_params['DeliveryPhone'].should == "0123456789"
        end

        it "should contain the customer email only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('CustomerEmail')

          transaction_registration.customer_email = "jimbob@example.com"
          transaction_registration.post_params['CustomerEmail'].should == "jimbob@example.com"
        end

        it "should contain the basket only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('Basket')

          transaction_registration.basket = "Sample basket"
          transaction_registration.post_params['Basket'].should == "Sample basket"
        end

        it "should contain allow_gift_aid only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('AllowGiftAid')

          transaction_registration.allow_gift_aid = true
          transaction_registration.post_params['AllowGiftAid'].should == "1"

          transaction_registration.allow_gift_aid = false
          transaction_registration.post_params['AllowGiftAid'].should == "0"
        end

        it "should contain apply_avs_cv2 only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('ApplyAVSCV2')

          transaction_registration.apply_avs_cv2 = 0
          transaction_registration.post_params['ApplyAVSCV2'].should == "0"

          transaction_registration.apply_avs_cv2 = 1
          transaction_registration.post_params['ApplyAVSCV2'].should == "1"

          transaction_registration.apply_avs_cv2 = 2
          transaction_registration.post_params['ApplyAVSCV2'].should == "2"

          transaction_registration.apply_avs_cv2 = 3
          transaction_registration.post_params['ApplyAVSCV2'].should == "3"
        end

        it "should contain apply_3d_secure only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('ApplyAVSCV2')

          transaction_registration.apply_3d_secure = 0
          transaction_registration.post_params['Apply3DSecure'].should == "0"

          transaction_registration.apply_3d_secure = 1
          transaction_registration.post_params['Apply3DSecure'].should == "1"

          transaction_registration.apply_3d_secure = 2
          transaction_registration.post_params['Apply3DSecure'].should == "2"

          transaction_registration.apply_3d_secure = 3
          transaction_registration.post_params['Apply3DSecure'].should == "3"
        end

        it "should contain profile only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('Profile')

          transaction_registration.profile = :normal
          transaction_registration.post_params['Profile'].should == "NORMAL"

          transaction_registration.profile = :low
          transaction_registration.post_params['Profile'].should == "LOW"
        end

        it "should contain billing_agreement only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('BillingAgreement')

          transaction_registration.billing_agreement = true
          transaction_registration.post_params['BillingAgreement'].should == "1"

          transaction_registration.billing_agreement = false
          transaction_registration.post_params['BillingAgreement'].should == "0"
        end

        it "should contain account type only if supplied" do
          transaction_registration = transaction_registration_factory
          transaction_registration.post_params.keys.should_not include('AccountType')

          transaction_registration.account_type = :ecommerce
          transaction_registration.post_params['AccountType'].should == "E"

          transaction_registration.account_type = :continuous_authority
          transaction_registration.post_params['AccountType'].should == "C"

          transaction_registration.account_type = :mail_order
          transaction_registration.post_params['AccountType'].should == "M"
        end
      end
    end
  end

  describe "#register!" do
    context "if SagePay is having a bad day" do
      before(:each) do
        @transaction_registration = transaction_registration_factory
        @transaction_registration.stub(:post).and_return(mock("HTTP Response", :code => "500"))
      end

      it "should raise an exception to say that we couldn't talk to SagePay" do
        lambda {
          @transaction_registration.register!
        }.should raise_error RuntimeError, "I guess SagePay doesn't like us today."
      end
    end

    context "when SagePay returns a useful response" do
      before(:each) do
        @mock_http_response = mock("HTTP response", :code => "200", :body => "mock response body")
        @mock_response = mock("Transaction registration response")
        @transaction_registration = transaction_registration_factory
        @transaction_registration.stub(:post).and_return(@mock_http_response)
        TransactionRegistrationResponse.stub(:from_response_body).and_return @mock_response
      end

      it "should return a newly created TransactionRegistrationResponse with the response" do
        response = @transaction_registration.register!
        response.should == @mock_response
      end

      it "should pass the response body to TransactionRegistrationResponse.from_response_body to let it parse and initialize" do
        TransactionRegistrationResponse.should_receive(:from_response_body).with("mock response body")
        @transaction_registration.register!
      end

      it "should post the request to SagePay" do
        @transaction_registration.should_receive(:post)
        @transaction_registration.register!
      end
    end
  end
end
