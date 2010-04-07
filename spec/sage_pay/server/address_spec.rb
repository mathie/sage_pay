require 'spec_helper'

describe SagePay::Server::Address do
  it "should be valid straight from the factory" do
    lambda {
      address_factory.should be_valid
    }.should_not raise_error
  end

  describe "validations" do
    it { validates_the_presence_of(:address, :first_names) }
    it { validates_the_presence_of(:address, :surname)     }
    it { validates_the_presence_of(:address, :address_1)   }
    it { validates_the_presence_of(:address, :city)        }
    it { validates_the_presence_of(:address, :post_code)   }
    it { validates_the_presence_of(:address, :country)     }

    it { does_not_require_the_presence_of(:address, :address_2) }
    it { does_not_require_the_presence_of(:address, :state)     }
    it { does_not_require_the_presence_of(:address, :phone)     }

    it { validates_the_length_of(:address, :first_names, :max => 20)  }
    it { validates_the_length_of(:address, :surname,     :max => 20)  }
    it { validates_the_length_of(:address, :address_1,   :max => 100) }
    it { validates_the_length_of(:address, :address_2,   :max => 100) }
    it { validates_the_length_of(:address, :city,        :max => 40)  }
    it { validates_the_length_of(:address, :post_code,   :max => 10)  }
    it { validates_the_length_of(:address, :phone,       :max => 20)  }

    it "validates the format of first names" do
      validates_the_format_of :address, :first_names,
        :valid => [
          "Bob", "Graham & Sarah", "John-Angus", "Graeme R.", "O'Brien", "Gr/\\eme"
        ],
        :invalid => [
          "mathie1979", "B()b", "mathie@woss.name"
        ]
    end

    it "validates the format of surname" do
      validates_the_format_of :address, :surname,
        :valid => [
          "Bob", "Graham & Sarah", "John-Angus", "Graeme R.", "O'Brien", "Gr/\\eme"
        ],
        :invalid => [
          "mathie1979", "B()b", "mathie@woss.name"
        ]
    end

    it "validates the format of address 1" do
      validates_the_format_of :address, :address_1,
      :valid => [
        "123 Any Street, Suburb", "123 Any Street\nSuburb",
        "123+ Al'Agrathia", "Attn: Bob & Sarah (not John-Angus)."
      ],
      :invalid => [
        "!", "_", ";", "@"
      ]
    end

    it "validates the format of address 2" do
      validates_the_format_of :address, :address_2,
      :valid => [
        "123 Any Street, Suburb", "123 Any Street\nSuburb",
        "123+ Al'Agrathia", "Attn: Bob & Sarah (not John-Angus)."
      ],
      :invalid => [
        "!", "_", ";", "@"
      ]
    end

    it "validates the format of city" do
      validates_the_format_of :address, :city,
      :valid => [
        "123 Any Street, Suburb", "123 Any Street\nSuburb",
        "123+ Al'Agrathia", "Attn: Bob & Sarah (not John-Angus)."
      ],
      :invalid => [
        "!", "_", ";", "@"
      ]
    end

    it "validates the format of post code" do
      validates_the_format_of :address, :post_code,
      :valid => [
        "AB12 3CD", "EH21-7PB"
      ],
      :invalid => [
        "AB&^3FG"
      ]
    end

    it "validates the format of phone" do
      validates_the_format_of :address, :phone,
      :valid => [
        "+44 (0)131 273 5271", "01312735271", "0131 CALL-FOR-HELP"
      ],
      :invalid => [
        "2735271 ext.3444"
      ]
    end

    it "should validate the state against a list of US states" do
      address = address_factory(:state => "WY")
      address.should be_valid
      address = address_factory(:state => "AA")
      address.should_not be_valid
      address.errors.on(:state).should == "is not a US state"
    end

    it "should validate the country against a list of ISO 3166-1 country codes" do
      address = address_factory(:country => "GB")
      address.should be_valid
      address = address_factory(:country => "AA")
      address.should_not be_valid
      address.errors.on(:country).should == "is not an ISO3166-1 country code"
    end
  end
end
