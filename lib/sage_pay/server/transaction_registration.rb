module SagePay
  module Server
    class TransactionRegistration
      attr_reader :vps_protocol
      attr_accessor :tx_type, :vendor, :vendor_tx_code,
        :amount, :currency, :description, :notification_url, :billing_address,
        :delivery_address, :customer_email, :basket, :allow_gift_aid,
        :apply_avs_cv2, :apply_3d_secure, :profile, :billing_agreement,
        :account_type

      def initialize(attributes = {})
        @vps_protocol = "2.23"

        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end