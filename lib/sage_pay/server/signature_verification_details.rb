module SagePay
  module Server
    class SignatureVerificationDetails
      attr_reader :vendor, :security_key

      def initialize(transaction_registration, transaction_registration_response)
        @vendor         = transaction_registration.vendor
        @security_key   = transaction_registration_response.security_key
      end
    end
  end
end
