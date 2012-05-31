require 'spec_helper'

describe SagePay::Server::Address do
  include ValidationMatchers
  it "should be valid straight from the factory" do
    lambda {
      address_factory.should be_valid
    }.should_not raise_error
  end

  describe "validations" do
    it { validate_presence_of(:first_names) }
    it { validate_presence_of(:surname)     }
    it { validate_presence_of(:address_1)   }
    it { validate_presence_of(:city)        }
    it { validate_presence_of(:post_code)   }
    it { validate_presence_of(:country)     }

    should_not_validate_presence_of(:address_2)
    should_not_validate_presence_of(:state)
    should_not_validate_presence_of(:phone)

    should_validate_length_of(:first_names, :maximum => 20)
    should_validate_length_of(:surname,     :maximum => 20)
    should_validate_length_of(:address_1,   :maximum => 100)
    should_validate_length_of(:address_2,   :maximum => 100)
    should_validate_length_of(:city,        :maximum => 40)
    should_validate_length_of(:post_code,   :maximum => 10)
    should_validate_length_of(:phone,       :maximum => 20)


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

    it "should require a US state to be present if the country is the US" do
      address = address_factory(:country => "US", :state => "")
      address.should_not be_valid
      address.errors[:state].should == ["is required if the country is US"]
    end

    it "should require the US state to be absent if the country is not in the US" do
      address = address_factory(:country => "GB", :state => "WY")
      address.should_not be_valid
      address.errors[:state].should == ["is present but the country is not US"]
    end

    it "should validate the state against a list of US states" do
      address = address_factory(:country => "US", :state => "WY")
      address.should be_valid
      address = address_factory(:country => "US", :state => "AA")
      address.should_not be_valid
      address.errors[:state].should == ["is not a US state"]
    end

    it "should validate the country against a list of ISO 3166-1 country codes" do
      address = address_factory(:country => "GB")
      address.should be_valid
      address = address_factory(:country => "AA")
      address.should_not be_valid
      address.errors[:country].should == ["is not an ISO3166-1 country code"]
    end
  end
end
