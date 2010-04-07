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

      def amount=(value)
        @amount = (value.nil? || (value.respond_to?(:empty?) && value.empty?)) ? nil : BigDecimal.new(value.to_s)
      end

    end
  end
end
