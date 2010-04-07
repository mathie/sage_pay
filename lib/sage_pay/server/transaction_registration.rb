module SagePay
  module Server
    class TransactionRegistration
      include Validatable

      attr_reader :vps_protocol
      attr_accessor :tx_type, :vendor, :vendor_tx_code,
        :amount, :currency, :description, :notification_url, :billing_address,
        :delivery_address, :customer_email, :basket, :allow_gift_aid,
        :apply_avs_cv2, :apply_3d_secure, :profile, :billing_agreement,
        :account_type

      validates_presence_of :vps_protocol, :tx_type, :vendor, :vendor_tx_code,
        :amount, :currency, :description, :notification_url, :billing_address,
        :delivery_address

      validates_length_of :vps_protocol,     :is      => 4
      validates_length_of :vendor,           :maximum => 15
      validates_length_of :vendor_tx_code,   :maximum => 40
      validates_length_of :currency,         :is      => 3
      validates_length_of :description,      :maximum => 100
      validates_length_of :notification_url, :maximum => 255
      validates_length_of :customer_email,   :maximum => 255
      validates_length_of :basket,           :maximum => 7_500

      def initialize(attributes = {})
        @vps_protocol = "2.23"

        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end