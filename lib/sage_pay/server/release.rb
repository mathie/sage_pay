module SagePay
  module Server
    class Release < Command
      attr_accessor :vps_tx_id, :security_key, :tx_auth_no
      decimal_accessor :release_amount

      validates_presence_of :vps_tx_id, :security_key, :tx_auth_no,
        :release_amount

      validates_length_of :vps_tx_id,        :is      => 38
      validates_length_of :security_key,     :is      => 10

      validates_inclusion_of :tx_type, :allow_blank => true, :in => [ :release ]

      validates_true_for :release_amount, :key => :release_amount_minimum_value, :logic => lambda { release_amount.nil? || release_amount >= BigDecimal.new("0.01")   }, :message => "is less than the minimum value (0.01)"
      validates_true_for :release_amount, :key => :release_amount_maximum_value, :logic => lambda { release_amount.nil? || release_amount <= BigDecimal.new("100000") }, :message => "is greater than the maximum value (100,000.00)"

      def initialize(attributes = {})
        @tx_type = :release
        super
      end

      def post_params
        super.merge({
          "VPSTxId" => vps_tx_id,
          "SecurityKey" => security_key,
          "TxAuthNo" => tx_auth_no,
          "ReleaseAmount" => ("%.2f" % release_amount)
        })
      end

      def live_service
        "release"
      end

      def simulator_service
        "VendorReleaseTx"
      end
    end
  end
end
