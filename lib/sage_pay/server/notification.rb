module SagePay
  module Server
    class Notification
      class_attribute :personal_credit_card_types, :instance_writer => false
      self.personal_credit_card_types = [ :visa, :mastercard ].freeze

      class_attribute :commercial_card_types, :instance_writer => false
      self.commercial_card_types = [ :american_express, :diners, :jcb ].freeze

      class_attribute :debit_card_types, :instance_writer => false
      self.debit_card_types = [ :visa_delta, :maestro, :visa_electron, :solo, :laser ].freeze

      attr_reader :vps_protocol, :tx_type, :vendor_tx_code, :vps_tx_id,
        :status, :status_detail, :tx_auth_no, :avs_cv2, :address_result,
        :post_code_result, :cv2_result, :gift_aid, :threed_secure_status,
        :cavv, :address_status, :payer_status,:card_type, :last_4_digits,
        :vps_signature

      def self.from_params(params, signature_verification_details = nil)
        params_converter = NotificationsParamsConverter.new(params)
        attributes = params_converter.convert

        if signature_verification_details.nil? && block_given?
          signature_verification_details = yield(attributes)
        end

        signature_verifier = SignatureVerifier.new(params, signature_verification_details)
        attributes[:calculated_hash] = signature_verifier.calculate_hash

        new(attributes)
      end

      def initialize(attributes = {})
        attributes.each do |k, v|
          next unless k
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

      def credit_card?
        personal_credit_card? || commercial_card?
      end

      def personal_credit_card?
        personal_credit_card_types.include?(card_type)
      end

      def commercial_card?
        commercial_card_types.include?(card_type)
      end

      def debit_card?
        debit_card_types.include?(card_type)
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
