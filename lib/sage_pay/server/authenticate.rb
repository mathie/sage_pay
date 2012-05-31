module SagePay
  module Server
    # This class was implemented due to some doubts of the
    class Authenticate < Command
      self.tx_type = :authenticate

      attr_accessor :currency, :description, :notification_url,
                    :billing_address, :delivery_address, :customer_email, :basket,
                    :allow_gift_aid, :apply_avs_cv2, :apply_3d_secure, :profile,
                    :billing_agreement, :account_type
      decimal_accessor :amount

      validates_presence_of :amount, :currency, :description,
                            :notification_url, :billing_address, :delivery_address

      validates_length_of :currency,         :is      => 3
      validates_length_of :description,      :maximum => 100
      validates_length_of :notification_url, :maximum => 255
      validates_length_of :customer_email,   :maximum => 255
      validates_length_of :basket,           :maximum => 7_500

      validates_inclusion_of :tx_type,           :allow_blank => true, :in => [ :authenticate ]
      validates_inclusion_of :allow_gift_aid,    :allow_blank => true, :in => [ true, false ]
      validates_inclusion_of :apply_avs_cv2,     :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :apply_3d_secure,   :allow_blank => true, :in => (0..3).to_a
      validates_inclusion_of :profile,           :allow_blank => true, :in => [:normal, :low]
      validates_inclusion_of :billing_agreement, :allow_blank => true, :in => [true, false]
      validates_inclusion_of :account_type,      :allow_blank => true, :in => [:ecommerce, :continuous_authority, :mail_order]

      validates :amount, :numericality => {:message => "is less than the minimum value (0.01)", :greater_than_or_equal_to => BigDecimal.new("0.01")}
      validates :amount, :numericality => {:message => "is greater than the maximum value (100,000.00)", :less_than_or_equal_to => BigDecimal.new("100000")}

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
          raise RuntimeError, "Not yet registered"
        elsif @response.failed?
          raise RuntimeError, "Registration failed"
        else
          @signature_verification_details ||= SignatureVerificationDetails.new(vendor, @response.security_key)
        end
      end

      def live_service
        "authenticate"
      end

      def simulator_service
        "VendorAuthenticateTx"
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
        params['BillingAddress2']  = billing_address.address_2     if billing_address.address_2.present?
        params['BillingState']     = billing_address.state         if billing_address.state.present?
        params['BillingPhone']     = billing_address.phone         if billing_address.phone.present?
        params['DeliveryAddress2'] = delivery_address.address_2    if delivery_address.address_2.present?
        params['DeliveryState']    = delivery_address.state        if delivery_address.state.present?
        params['DeliveryPhone']    = delivery_address.phone        if delivery_address.phone.present?
        params['CustomerEmail']    = customer_email                if customer_email.present?
        params['Basket']           = basket                        if basket.present?
        params['AllowGiftAid']     = allow_gift_aid ? "1" : "0"    if allow_gift_aid.present? || allow_gift_aid == false
        params['ApplyAVSCV2']      = apply_avs_cv2.to_s            if apply_avs_cv2.present?
        params['Apply3DSecure']    = apply_3d_secure.to_s          if apply_3d_secure.present?
        params['Profile']          = profile.to_s.upcase           if profile.present?
        params['BillingAgreement'] = billing_agreement ? "1" : "0" if billing_agreement.present? || billing_agreement == false
        params['AccountType']      = account_type_param            if account_type.present?

        # And return the completed hash
        params
      end

      def response_from_response_body(response_body)
        RegistrationResponse.from_response_body(response_body)
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
