module SagePay
  module Server
    class RegistrationResponse < Response
      self.key_converter = key_converter.merge({
        "VPSTxId"      => :vps_tx_id,
        "SecurityKey"  => :security_key,
        "NextURL"      => :next_url
      })

      def vps_tx_id
        if ok?
          @vps_tx_id
        else
          raise RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
        end
      end

      def security_key
        if ok?
          @security_key
        else
          raise RuntimeError, "Unable to retrieve the security key as the status was not OK."
        end
      end

      def next_url
        if ok?
          @next_url
        else
          raise RuntimeError, "Unable to retrieve the next URL as the status was not OK."
        end
      end
    end
  end
end
