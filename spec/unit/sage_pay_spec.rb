require 'spec_helper'

describe SagePay do
  it "should be version 0.1.0" do
    SagePay::VERSION.should == '0.1.0'
  end
end

describe SagePay::Server::Address do
  def address_factory(overrides = {})
    # Data provided courtesy of Faker
    address = SagePay::Server::Address.new :first_names => "Aryanna", :surname => "Larkin",
      :address_1 => "19313 Cristian Parks", :city => "Lurlineport",
      :post_code => "UI62 7BJ", :country => "Wales"

    overrides.each do |k,v|
      address.send("#{k}=", v)
    end

    address
  end

  def validates_the_presence_of(attribute, message = "can't be empty")
    address = address_factory(attribute => "")
    address.should_not be_valid
    address.errors.on(attribute).should == message
  end

  def does_not_validate_the_presence_of(attribute)
    address = address_factory(attribute => "")
    address.should be_valid
    address.errors.on(attribute).should be_nil
  end

  it "should be valid straight from the factory" do
    lambda {
      address_factory.should be_valid
    }.should_not raise_error
  end

  describe "validations" do
    it { validates_the_presence_of(:first_names) }
    it { validates_the_presence_of(:surname)     }
    it { validates_the_presence_of(:address_1)   }
    it { validates_the_presence_of(:city)        }
    it { validates_the_presence_of(:post_code)   }
    it { validates_the_presence_of(:country)     }

    it { does_not_validate_the_presence_of(:address_2) }
    it { does_not_validate_the_presence_of(:state)     }
    it { does_not_validate_the_presence_of(:phone)     }
  end
end
