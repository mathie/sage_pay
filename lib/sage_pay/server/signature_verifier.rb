module SagePay
  module Server
    class SignatureVerifier
      def initialize(params, signature_verification_details)

        @params = params
        @signature_verification_details = signature_verification_details
      end

      def calculate_hash
        return nil if @signature_verification_details.nil?

        Digest::MD5.hexdigest(fields_used_in_signature.join).upcase
      end

      private
      def fields_used_in_signature
        [
          @params["VPSTxId"],
          @params["VendorTxCode"],
          @params["Status"],
          @params["TxAuthNo"],
          @signature_verification_details.vendor,
          @params["AVSCV2"],
          @signature_verification_details.security_key,
          @params["AddressResult"],
          @params["PostCodeResult"],
          @params["CV2Result"],
          @params["GiftAid"],
          @params["3DSecureStatus"],
          @params["CAVV"],
          @params["AddressStatus"],
          @params["PayerStatus"],
          @params["CardType"],
          @params["Last4Digits"]
        ]
      end
    end
  end
end
