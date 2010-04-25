module SagePay
  module Server
    class Authorise < Command
      attr_accessor :amount, :description, :related_transaction, :apply_avs_cv2

      validates_presence_of :amount, :description, :related_transaction

      validates_length_of :description, :maximum => 100

      validates_inclusion_of :tx_type,       :allow_blank => true, :in => [ :authorise ]
      validates_inclusion_of :apply_avs_cv2, :allow_blank => true, :in => (0..3).to_a

      validates_true_for :amount, :key => :amount_minimum_value, :logic => lambda { amount.nil? || amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :amount, :key => :amount_maximum_value, :logic => lambda { amount.nil? || amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def initialize(attributes = {})
        @tx_type = :authorise
        super
      end

      def post_params
        params = super.merge({
          "Amount"      => ("%.2f" % amount),
          "Description" => description
        }).merge(related_transaction.post_params)

        params['ApplyAVSCV2'] = apply_avs_cv2.to_s if apply_avs_cv2.present?

        params
      end

      def amount=(value)
        @amount = blank?(value) ? nil : BigDecimal.new(value.to_s)
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
