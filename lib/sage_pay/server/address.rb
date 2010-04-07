module SagePay
  module Server
    class Address
      include Validatable

      class << self
        attr_accessor :us_states, :iso_3166_country_codes
      end
      self.us_states = ["AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "FM", "GA", "GU", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MH", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "PW", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY"]
      self.iso_3166_country_codes = ["AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM", "BT", "BO", "BA", "BW", "BV", "BR", "IO", "BN", "BG", "BF", "BI", "KH", "CM", "CA", "CV", "KY", "CF", "TD", "CL", "CN", "CX", "CC", "CO", "KM", "CG", "CD", "CK", "CR", "CI", "HR", "CU", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "GQ", "ER", "EE", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF", "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GG", "GN", "GW", "GY", "HT", "HM", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IR", "IQ", "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KP", "KR", "KW", "KG", "LA", "LV", "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO", "MK", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MD", "MC", "MN", "ME", "MS", "MA", "MZ", "MM", "NA", "NR", "NP", "NL", "AN", "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MP", "OM", "PK", "PW", "PS", "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE", "RO", "RU", "RW", "BL", "SH", "KN", "LC", "MF", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SK", "SI", "SB", "SO", "ZA", "GS", "ES", "LK", "SD", "SR", "SJ", "SZ", "SE", "CH", "SY", "TW", "TJ", "TZ", "TH", "TL", "TG", "TK", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "US", "UM", "UY", "UZ", "VU", "VE", "VN", "VG", "VI", "WF", "EH", "YE", "ZM", "ZW"]

      attr_accessor :first_names, :surname, :address_1, :address_2, :city,
        :post_code, :country, :state, :phone

      validates_presence_of :first_names, :surname, :address_1, :city, :post_code, :country

      # FIXME: This regexp isn't correctly matching accented characters. I
      # think it's a Ruby version issue so I'm punting for the moment.
      validates_format_of :first_names, :surname, :with => /^[[:alpha:] \\\/&'\.\-]*$/
      validates_format_of :address_1, :address_2, :city, :with => /^[[:alnum:][:space:]\+\\\/&'\.:,\(\)\-]*$/
      validates_format_of :post_code, :with => /^[[:alnum:] -]*$/
      validates_format_of :phone, :with => /^[[:alnum:] \+\(\)-]*$/

      validates_length_of :first_names, :surname, :maximum => 20
      validates_length_of :address_1, :address_2, :maximum => 100
      validates_length_of :city, :maximum => 40
      validates_length_of :post_code, :maximum => 10
      validates_length_of :phone, :maximum => 20

      # While the spec specifies the lengths of these columns, we're
      # validating that they're included in our list, and our list only
      # contains two-character strings, so this validation has no real win.
      # validates_length_of :country, :state, :maximum => 2

      validates_inclusion_of :state,   :in => us_states,              :allow_blank => true, :message => "is not a US state"
      validates_inclusion_of :country, :in => iso_3166_country_codes, :allow_blank => true, :message => "is not an ISO3166-1 country code"

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end
