module SagePay
  module Server
    class Abort < Command
      self.tx_type = :abort

      attr_accessor :vps_tx_id, :security_key, :tx_auth_no

      validates_presence_of :vps_tx_id, :security_key, :tx_auth_no

      validates_length_of :vps_tx_id,    :is => 38
      validates_length_of :security_key, :is => 10

      def post_params
        super.merge({
          "VPSTxId" => vps_tx_id,
          "SecurityKey" => security_key,
          "TxAuthNo" => tx_auth_no,
        })
      end
      def live_service
        "abort"
      end

      def simulator_service
        "VendorAbortTx"
      end
    end
  end
end
