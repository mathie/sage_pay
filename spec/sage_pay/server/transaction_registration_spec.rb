require 'spec_helper'

describe SagePay::Server::TransactionRegistration do
  it "should work straight from the factory" do
    lambda {
      transaction_registration_factory.should be_valid
    }.should_not raise_error
  end

  it "should report protocol version 2.23" do
    transaction_registration = SagePay::Server::TransactionRegistration.new
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
end
