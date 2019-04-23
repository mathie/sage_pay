module SagePay
  module Server
    class Authorise < Command
      self.tx_type = :authorise

      attr_accessor :description, :related_transaction, :apply_avs_cv2
      decimal_accessor :amount

      validates_presence_of :amount, :description, :related_transaction

      validates_length_of :description, :maximum => 100

      validates_inclusion_of :apply_avs_cv2, :allow_blank => true, :in => (0..3).to_a

      validates :amount, :numericality => {:message => "is less than the minimum value (0.01)", :greater_than_or_equal_to => BigDecimal("0.01")}
      validates :amount, :numericality => {:message => "is greater than the maximum value (100,000.00)", :less_than_or_equal_toi => BigDecimal("100000")}

      def post_params
        params = super.merge({
          "Amount"      => ("%.2f" % amount),
          "Description" => description
        }).merge(related_transaction.post_params)

        params['ApplyAVSCV2'] = apply_avs_cv2.to_s if apply_avs_cv2.present?

        params
      end

      def response_from_response_body(response_body)
        # FIXME: Since RepeatResponse is being shared for repeats and
        # authorisations, it should probably be renamed.
        RepeatResponse.from_response_body(response_body)
      end

      def live_service
        "authorise"
      end

      def simulator_service
        "VendorAuthoriseTx"
      end
    end
  end
end
