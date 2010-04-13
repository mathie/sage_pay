module SagePay
  module Server
    class SignatureVerificationDetails
      attr_reader :vps_tx_id, :vendor_tx_code, :vendor, :security_key

      def initialize(transaction_registration, transaction_registration_response)
        @vendor_tx_code = transaction_registration.vendor_tx_code
        @vendor         = transaction_registration.vendor
        @vps_tx_id      = transaction_registration_response.vps_tx_id
        @security_key   = transaction_registration_response.security_key
      end
    end
  end
end
