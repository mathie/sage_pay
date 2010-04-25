module SagePay
  module Server
    class Refund < Command
      attr_accessor :amount, :currency, :description, :related_transaction

      validates_presence_of :amount, :currency, :description, :related_transaction

      validates_length_of :currency,    :is      => 3
      validates_length_of :description, :maximum => 100

      validates_inclusion_of :tx_type, :allow_blank => true, :in => [ :refund ]

      validates_true_for :amount, :key => :amount_minimum_value, :logic => lambda { amount.nil? || amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :amount, :key => :amount_maximum_value, :logic => lambda { amount.nil? || amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def initialize(attributes = {})
        @tx_type = :refund
        super
      end

      def post_params
        super.merge({
          "Amount"      => ("%.2f" % amount),
          "Currency"    => currency,
          "Description" => description
        }).merge(related_transaction.post_params)
      end

      def amount=(value)
        @amount = blank?(value) ? nil : BigDecimal.new(value.to_s)
      end

      def response_from_response_body(response_body)
        RefundResponse.from_response_body(response_body)
      end

      def live_service
        "refund"
      end

      def simulator_service
        "VendorRefundTx"
      end
    end
  end
end
