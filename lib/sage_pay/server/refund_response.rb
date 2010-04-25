module SagePay
  module Server
    class RefundResponse < Response
      attr_accessor_if_ok :vps_tx_id, :tx_auth_no

      self.key_converter = key_converter.merge({
        "VPSTxId"  => :vps_tx_id,
        "TxAuthNo" => :tx_auth_no
      })

      self.value_converter[:status]["NOTAUTHED"] = :not_authed

      def vps_tx_id
        if ok?
          @vps_tx_id
        else
          raise RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
        end
      end

      def tx_auth_no
        if ok?
          @tx_auth_no
        else
          raise RuntimeError, "Unable to retrieve the authorisation number as the status was not OK."
        end
      end
    end
  end
end
