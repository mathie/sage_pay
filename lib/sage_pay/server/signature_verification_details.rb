module SagePay
  module Server
    class SignatureVerificationDetails
      attr_reader :vendor, :security_key

      def initialize(vendor, security_key)
        @vendor         = vendor
        @security_key   = security_key
      end
    end
  end
end
