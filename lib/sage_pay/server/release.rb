module SagePay
  module Server
    class Release < Command
      self.tx_type = :release

      attr_accessor :vps_tx_id, :security_key, :tx_auth_no
      decimal_accessor :release_amount

      validates_presence_of :vps_tx_id, :security_key, :tx_auth_no,
        :release_amount

      validates_length_of :vps_tx_id,        :is      => 38
      validates_length_of :security_key,     :is      => 10

      validates :amount, :numericality => {:message => "is less than the minimum value (0.01)", :greater_than_or_equal_to => BigDecimal("0.01")}
      validates :amount, :numericality => {:message => "is greater than the maximum value (100,000.00)", :less_than_or_equal_to => BigDecimal("100000")}

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
