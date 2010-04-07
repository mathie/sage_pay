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

  end
end
