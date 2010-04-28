module SagePay
  module Server
    class Cancel < Command
      self.tx_type = :cancel

      attr_accessor :vps_tx_id, :security_key

      validates_presence_of :vps_tx_id, :security_key

      validates_length_of :vps_tx_id,    :is => 38
      validates_length_of :security_key, :is => 10

      def post_params
        super.merge({
          "VPSTxId" => vps_tx_id,
          "SecurityKey" => security_key
        })
      end

      def live_service
        "cancel"
      end

      def simulator_service
        "VendorCancelTx"
      end
    end
  end
end
