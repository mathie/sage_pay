module SagePay
  class Server

    class Address
      include Validatable

      attr_accessor :first_names, :surname, :address_1, :address_2, :city,
        :post_code, :country, :state, :phone

      validates_presence_of :first_names, :surname, :address_1, :city, :post_code, :country

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end
    end

    class TransactionRegistration
      attr_accessor :vps_protocol, :tx_type, :vendor, :vendor_tx_code,
        :amount, :currency, :description, :notification_url, :billing_address,
        :delivery_address, :customer_email, :basket, :allow_gift_aid,
        :apply_avs_cv2, :apply_3d_secure, :profile, :billing_agreement,
        :account_type

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end
