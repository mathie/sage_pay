module SagePay
  module Server
    class Refund < Command
      self.tx_type = :refund

      attr_accessor :currency, :description, :related_transaction
      decimal_accessor :amount

      validates_presence_of :amount, :currency, :description, :related_transaction

      validates_length_of :currency,    :is      => 3
      validates_length_of :description, :maximum => 100

      validates :amount, :numericality => {:message => "is less than the minimum value (0.01)", :greater_than_or_equal_to => BigDecimal("0.01")}
      validates :amount, :numericality => {:message => "is greater than the maximum value (100,000.00)", :less_than_or_equal_to => BigDecimal("100000")}

      def post_params
        super.merge({
          "Amount"      => ("%.2f" % amount),
          "Currency"    => currency,
          "Description" => description
        }).merge(related_transaction.post_params)
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
