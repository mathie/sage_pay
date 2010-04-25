module SagePay
  module Server
    class Notification
      attr_reader :vps_protocol, :tx_type, :vendor_tx_code, :vps_tx_id,
        :status, :status_detail, :tx_auth_no, :avs_cv2, :address_result,
        :post_code_result, :cv2_result, :gift_aid, :threed_secure_status,
        :cavv, :address_status, :payer_status,:card_type, :last_4_digits,
        :vps_signature

      def self.from_params(params, signature_verification_details = nil)
        key_converter = {
          "VPSProtocol"    => :vps_protocol,
          "TxType"         => :tx_type,
          "VendorTxCode"   => :vendor_tx_code,
          "VPSTxId"        => :vps_tx_id,
          "Status"         => :status,
          "StatusDetail"   => :status_detail,
          "TxAuthNo"       => :tx_auth_no,
          "AVSCV2"         => :avs_cv2,
          "AddressResult"  => :address_result,
          "PostCodeResult" => :post_code_result,
          "CV2Result"      => :cv2_result,
          "GiftAid"        => :gift_aid,
          "3DSecureStatus" => :threed_secure_status,
          "CAVV"           => :cavv,
          "AddressStatus"  => :address_status,
          "PayerStatus"    => :payer_status,
          "CardType"       => :card_type,
          "Last4Digits"    => :last_4_digits,
          "VPSSignature"   => :vps_signature
        }

        match_converter = {
          "NOTPROVIDED" => :not_provided,
          "NOTCHECKED"  => :not_checked,
          "MATCHED"     => :matched,
          "NOTMATCHED"  => :not_matched
        }

        true_false_converter = {
          "0" => false,
          "1" => true
        }

        value_converter = {
          :tx_type => {
            "PAYMENT"      => :payment,
            "DEFERRED"     => :deferred,
            "AUTHENTICATE" => :authenticate
          },
          :status => {
            "OK"            => :ok,
            "NOTAUTHED"     => :not_authed,
            "ABORT"         => :abort,
            "REJECTED"      => :rejected,
            "AUTHENTICATED" => :authenticated,
            "REGISTERED"    => :registered,
            "ERROR"         => :error
          },
          :avs_cv2 => {
            "ALL MATCH"                => :all_match,
            "SECURITY CODE MATCH ONLY" => :security_code_match_only,
            "ADDRESS MATCH ONLY"       => :address_match_only,
            "NO DATA MATCHES"          => :no_data_matches,
            "DATA NOT CHECKED"         => :data_not_checked
          },
          :address_result   => match_converter,
          :post_code_result => match_converter,
          :cv2_result       => match_converter,
          :gift_aid         => true_false_converter,
          :threed_secure_status => {
            "OK"           => :ok,
            "NOTCHECKED"   => :not_checked,
            "NOTAVAILABLE" => :not_available,
            "NOTAUTHED"    => :not_authed,
            "INCOMPLETE"   => :incomplete,
            "ERROR"        => :error
          },
          :address_status => {
            "NONE"        => :none,
            "CONFIRMED"   => :confirmed,
            "UNCONFIRMED" => :unconfirmed
          },
          :payer_status => {
            "VERIFIED"   => :verified,
            "UNVERIFIED" => :unverified
          },
          :card_type => {
            "VISA"    => :visa,
            "MC"      => :mastercard,
            "DELTA"   => :visa_delta,
            "SOLO"    => :solo,
            "MAESTRO" => :maestro,
            "UKE"     => :visa_electron,
            "AMEX"    => :american_express,
            "DC"      => :diners,
            "JCB"     => :jcb,
            "LASER"   => :laser,
            "PAYPAL"  => :paypal
          }
        }

        attributes = {}
        params.each do |key, value|
          unless value.nil?
            converted_key = key_converter[key]
            converted_value = value_converter[converted_key].nil? ? value : value_converter[converted_key][value]

            attributes[converted_key] = converted_value
          end
        end

        if signature_verification_details.nil? && block_given?
          signature_verification_details = yield(attributes)
        end

        unless signature_verification_details.nil?
          # We need to calculate the VPS signature from the values passed in as
          # additional params from the original registration and notification.
          fields_used_in_signature = [
            params["VPSTxId"],
            params["VendorTxCode"],
            params["Status"],
            params["TxAuthNo"],
            signature_verification_details.vendor,
            params["AVSCV2"],
            signature_verification_details.security_key,
            params["AddressResult"],
            params["PostCodeResult"],
            params["CV2Result"],
            params["GiftAid"],
            params["3DSecureStatus"],
            params["CAVV"],
            params["AddressStatus"],
            params["PayerStatus"],
            params["CardType"],
            params["Last4Digits"]
          ]
          attributes[:calculated_hash] = MD5.md5(fields_used_in_signature.join).to_s.upcase
        end

        new(attributes)
      end

      def initialize(attributes = {})
        attributes.each do |k, v|
          # We're only providing readers, not writers, so we have to directly
          # set the instance variable.
          instance_variable_set("@#{k}", v)
        end
      end

      def ok?
        status == :ok
      end

      def avs_cv2_matched?
        avs_cv2 == :all_match
      end

      def address_matched?
        address_result == :matched
      end

      def post_code_matched?
        post_code_result == :matched
      end

      def cv2_matched?
        cv2_result == :matched
      end

      def threed_secure_status_ok?
        threed_secure_status == :ok
      end

      def valid_signature?
        @calculated_hash == vps_signature
      end

      def response(redirect_url)
        if valid_signature?
          SagePay::Server::NotificationResponse.new(:status => :ok, :redirect_url => redirect_url)
        else
          SagePay::Server::NotificationResponse.new(:status => :invalid, :redirect_url => redirect_url, :status_detail => "Signature did not match our expectations")
        end.response
      end
    end
  end
end
