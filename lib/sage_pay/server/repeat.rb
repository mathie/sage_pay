module SagePay
  module Server
    class Repeat < Command
      attr_accessor :currency, :description, :related_transaction, :cv2
      decimal_accessor :amount

      validates_presence_of :amount, :currency, :description, :related_transaction

      validates_length_of :currency,    :is      => 3
      validates_length_of :description, :maximum => 100

      validates_inclusion_of :tx_type, :allow_blank => true, :in => [ :repeat ]

      validates_true_for :amount, :key => :amount_minimum_value, :logic => lambda { amount.nil? || amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :amount, :key => :amount_maximum_value, :logic => lambda { amount.nil? || amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def initialize(attributes = {})
        @tx_type = :repeat
        super
      end

      def post_params
        params = super.merge({
          "Amount"      => ("%.2f" % amount),
          "Currency"    => currency,
          "Description" => description
        }).merge(related_transaction.post_params)

        params["CV2"] = cv2 if cv2.present?

        params
      end

      def response_from_response_body(response_body)
        RepeatResponse.from_response_body(response_body)
      end

      def live_service
        "repeat"
      end

      def simulator_service
        "VendorRepeatTx"
      end
    end
  end
end
