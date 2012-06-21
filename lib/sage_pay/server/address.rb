module SagePay
  module Server
    class Address
      include ActiveModel::Validations

      attr_accessor :first_names, :surname, :address_1, :address_2, :city,
        :post_code, :country, :state, :phone

      validates_presence_of :first_names, :surname, :address_1, :city, :post_code, :country

      # FIXME: This regexp isn't correctly matching accented characters. I
      # think it's a Ruby version issue so I'm punting for the moment.
      validates_format_of :first_names, :surname, :with => NameFormat
      validates_format_of :address_1, :address_2, :city, :with => AddressFormat
      validates_format_of :post_code, :with => PostCodeFormat
      validates_format_of :phone, :with => PhoneFormat

      validates_length_of :first_names, :surname, :maximum => 20
      validates_length_of :address_1, :address_2, :maximum => 100
      validates_length_of :city, :maximum => 40
      validates_length_of :post_code, :maximum => 10
      validates_length_of :phone, :maximum => 20

      # While the spec specifies the lengths of these columns, we're
      # validating that they're included in our list, and our list only
      # contains two-character strings, so this validation has no real win.
      # validates_length_of :country, :state, :maximum => 2

      validates_inclusion_of :state,   :in => USStateOptions, :allow_blank => true, :message => "is not a US state"
      validates_inclusion_of :country, :in => CountryOptions, :allow_blank => true, :message => "is not an ISO3166-1 country code"

      # The state's presence is required if the country is the US, and
      # verboten otherwise.

      validates :state, :presence => {:message => "is required if the country is US"}, :if => :in_us?
      validates :state, :acceptance => { :accept => nil, :message => "is present but the country is not US" }, :unless => :in_us?

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def in_us?
        country == "US"
      end
    end
  end
end
