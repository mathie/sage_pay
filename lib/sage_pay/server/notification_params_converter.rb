module SagePay
  module Server
    class NotificationsParamsConverter
      class_attribute :key_converter, :instance_writer => false
      self.key_converter = {
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
      }.freeze

      class_attribute :match_converter, :instance_writer => false
      self.match_converter = {
        "NOTPROVIDED" => :not_provided,
        "NOTCHECKED"  => :not_checked,
        "MATCHED"     => :matched,
        "NOTMATCHED"  => :not_matched
      }

      class_attribute :true_false_converter, :instance_writer => false
      self.true_false_converter = {
        "0" => false,
        "1" => true
      }

      class_attribute :value_converter, :instance_writer => false
      self.value_converter = {
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

      def initialize(params)
        @params = params
      end

      def convert
        {}.tap do |attributes|
          @params.each do |key, value|
            next if value.nil?

            converted_key = key_converter[key]
            attributes[converted_key] = convert_value(converted_key, value)
          end
        end
      end

      private
      def convert_key(key)
        key_converter[key]
      end

      def convert_value(converted_key, value)
        value_converter[converted_key].nil? ? value : value_converter[converted_key][value]
      end
    end
  end
end
