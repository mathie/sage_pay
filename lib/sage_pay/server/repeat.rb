module SagePay
  module Server
    class Repeat < Command
      self.tx_type = :repeat

      attr_accessor :currency, :description, :related_transaction, :cv2
      decimal_accessor :amount

      validates_presence_of :amount, :currency, :description, :related_transaction

      validates_length_of :currency,    :is      => 3
      validates_length_of :description, :maximum => 100

      validates :amount, :numericality => {:message => "is less than the minimum value (0.01)", :greater_than_or_equal_to => BigDecimal("0.01")}
      validates :amount, :numericality => {:message => "is greater than the maximum value (100,000.00)", :less_than_or_equal_toi => BigDecimal("100000")}

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
