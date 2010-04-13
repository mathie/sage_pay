module SagePay
  module Server
    class TransactionRegistration
      include Validatable

      attr_reader :vps_protocol
      attr_accessor :mode, :tx_type, :vendor, :vendor_tx_code,
        :amount, :currency, :description, :notification_url, :billing_address,
        :delivery_address, :customer_email, :basket, :allow_gift_aid,
        :apply_avs_cv2, :apply_3d_secure, :profile, :billing_agreement,
        :account_type

      validates_presence_of :mode, :vps_protocol, :tx_type, :vendor,
        :vendor_tx_code, :amount, :currency, :description, :notification_url,
        :billing_address, :delivery_address

      validates_length_of :vps_protocol,     :is      => 4
      validates_length_of :vendor,           :maximum => 15
      validates_length_of :vendor_tx_code,   :maximum => 40
      validates_length_of :currency,         :is      => 3
      validates_length_of :description,      :maximum => 100
      validates_length_of :notification_url, :maximum => 255
      validates_length_of :customer_email,   :maximum => 255
      validates_length_of :basket,           :maximum => 7_500

      validates_inclusion_of :mode,              :allow_blank => true, :in => [ :simulator, :test, :live ]
      validates_inclusion_of :tx_type,           :allow_blank => true, :in => [ :payment, :deferred, :authenticate ]
      validates_inclusion_of :allow_gift_aid,    :allow_blank => true, :in => [ true, false ]
      validates_inclusion_of :apply_avs_cv2,     :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :apply_3d_secure,   :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :profile,           :allow_blank => true, :in => [:normal, :low]
      validates_inclusion_of :billing_agreement, :allow_blank => true, :in => [true, false]
      validates_inclusion_of :account_type,      :allow_blank => true, :in => [:ecommerce, :continuous_authority, :mail_order]

      validates_true_for :amount, :key => :amount_minimum_value, :logic => lambda { amount.nil? || amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :amount, :key => :amount_maximum_value, :logic => lambda { amount.nil? || amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def initialize(attributes = {})
        # Effectively hard coded for now
        @vps_protocol = "2.23"

        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def register!
        @response ||= handle_response(post)
      end

      def signature_verification_details
        if @response.nil?
          raise RuntimeError, "Transaction not yet registered"
        elsif @response.failed?
          raise RuntimeError, "Transaction registration failed"
        else
          SignatureVerificationDetails.new(self, @response)
        end
      end

      def url
        case mode
        when :simulator
          "https://test.sagepay.com/simulator/VSPServerGateway.asp?Service=VendorRegisterTx"
        when :test
          "https://test.sagepay.com/gateway/service/vspserver-register.vsp"
        when :live
          "https://live.sagepay.com/gateway/service/vspserver-register.vsp"
        else
          raise ArgumentError, "Invalid transaction mode"
        end
      end

      def post_params
        raise ArgumentError, "Invalid transaction registration options (see errors hash for details)" unless valid?

        # Mandatory parameters that we've already validated are present
        params = {
          "VPSProtocol"        => vps_protocol,
          "TxType"             => tx_type.to_s.upcase,
          "Vendor"             => vendor,
          "VendorTxCode"       => vendor_tx_code,
          "Amount"             => ("%.2f" % amount),
          "Currency"           => currency.upcase,
          "Description"        => description,
          "NotificationURL"    => notification_url,
          "BillingSurname"     => billing_address.surname,
          "BillingFirstnames"  => billing_address.first_names,
          "BillingAddress1"    => billing_address.address_1,
          "BillingCity"        => billing_address.city,
          "BillingPostCode"    => billing_address.post_code,
          "BillingCountry"     => billing_address.country,
          "DeliverySurname"    => delivery_address.surname,
          "DeliveryFirstnames" => delivery_address.first_names,
          "DeliveryAddress1"   => delivery_address.address_1,
          "DeliveryCity"       => delivery_address.city,
          "DeliveryPostCode"   => delivery_address.post_code,
          "DeliveryCountry"    => delivery_address.country,
        }

        # Optional parameters that are only inserted if they are present
        params['BillingAddress2']  = billing_address.address_2     if present?(billing_address.address_2)
        params['BillingState']     = billing_address.state         if present?(billing_address.state)
        params['BillingPhone']     = billing_address.phone         if present?(billing_address.phone)
        params['DeliveryAddress2'] = delivery_address.address_2    if present?(delivery_address.address_2)
        params['DeliveryState']    = delivery_address.state        if present?(delivery_address.state)
        params['DeliveryPhone']    = delivery_address.phone        if present?(delivery_address.phone)
        params['CustomerEmail']    = customer_email                if present?(customer_email)
        params['Basket']           = basket                        if present?(basket)
        params['AllowGiftAid']     = allow_gift_aid ? "1" : "0"    if present?(allow_gift_aid)
        params['ApplyAVSCV2']      = apply_avs_cv2.to_s            if present?(apply_avs_cv2)
        params['Apply3DSecure']    = apply_3d_secure.to_s          if present?(apply_3d_secure)
        params['Profile']          = profile.to_s.upcase           if present?(profile)
        params['BillingAgreement'] = billing_agreement ? "1" : "0" if present?(billing_agreement)
        params['AccountType']      = account_type_param            if present?(account_type)

        # And return the completed hash
        params
      end

      def amount=(value)
        @amount = blank?(value) ? nil : BigDecimal.new(value.to_s)
      end

      private

      def post
        parsed_uri = URI.parse(url)
        request = Net::HTTP::Post.new(parsed_uri.request_uri)
        request.form_data = post_params

        http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
        http.use_ssl = true if parsed_uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      def handle_response(response)
        case response.code.to_i
        when 200
          TransactionRegistrationResponse.from_response_body(response.body)
        else
          # FIXME: custom error response would be nice.
          raise RuntimeError, "I guess SagePay doesn't like us today."
        end
      end

      def account_type_param
        case account_type
        when :ecommerce
          'E'
        when :continuous_authority
          'C'
        when :mail_order
          'M'
        else
          raise ArgumentError, "account type is an invalid value: #{account_type}"
        end
      end

      def present?(value)
        !blank?(value)
      end

      def blank?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end
  end
end
