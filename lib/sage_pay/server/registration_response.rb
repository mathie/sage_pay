module SagePay
  module Server
    class RegistrationResponse < Response
      attr_accessor_if_ok :vps_tx_id, :security_key, :next_url

      self.key_converter = key_converter.merge({
        "VPSTxId"      => :vps_tx_id,
        "SecurityKey"  => :security_key,
        "NextURL"      => :next_url
      })
    end
  end
end
