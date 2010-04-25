module SagePay
  module Server
    class TransactionRegistration < Command
      attr_accessor :amount, :currency, :description, :notification_url,
        :billing_address, :delivery_address, :customer_email, :basket,
        :allow_gift_aid, :apply_avs_cv2, :apply_3d_secure, :profile,
        :billing_agreement, :account_type

      validates_presence_of :amount, :currency, :description,
        :notification_url, :billing_address, :delivery_address

      validates_length_of :currency,         :is      => 3
      validates_length_of :description,      :maximum => 100
      validates_length_of :notification_url, :maximum => 255
      validates_length_of :customer_email,   :maximum => 255
      validates_length_of :basket,           :maximum => 7_500

      validates_inclusion_of :tx_type,           :allow_blank => true, :in => [ :payment, :deferred, :authenticate ]
      validates_inclusion_of :allow_gift_aid,    :allow_blank => true, :in => [ true, false ]
      validates_inclusion_of :apply_avs_cv2,     :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :apply_3d_secure,   :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :profile,           :allow_blank => true, :in => [:normal, :low]
      validates_inclusion_of :billing_agreement, :allow_blank => true, :in => [true, false]
      validates_inclusion_of :account_type,      :allow_blank => true, :in => [:ecommerce, :continuous_authority, :mail_order]

      validates_true_for :amount, :key => :amount_minimum_value, :logic => lambda { amount.nil? || amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :amount, :key => :amount_maximum_value, :logic => lambda { amount.nil? || amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def run!
        if @response.nil? || (@vendor_tx_code_sent != vendor_tx_code)
          @vendor_tx_code_sent = vendor_tx_code
          @response = handle_response(post)
        else
          raise RuntimeError, "This vendor transaction code has already been registered"
        end
      end

      def signature_verification_details
        if @response.nil?
          raise RuntimeError, "Transaction not yet registered"
        elsif @response.failed?
          raise RuntimeError, "Transaction registration failed"
        else
          @signature_verification_details ||= SignatureVerificationDetails.new(vendor, @response.security_key)
        end
      end

      def live_service
        "vspserver-register"
      end

      def simulator_service
        "VendorRegisterTx"
      end

      def post_params
        params = super.merge({
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
        })

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

      def response_from_response_body(response_body)
        TransactionRegistrationResponse.from_response_body(response_body)
      end

      def amount=(value)
        @amount = blank?(value) ? nil : BigDecimal.new(value.to_s)
      end

      private
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
    end
  end
end
