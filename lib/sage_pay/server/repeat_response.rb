module SagePay
  module Server
    class RepeatResponse < Response
      attr_accessor_if_ok :vps_tx_id, :tx_auth_no, :security_key,
        :avs_cv2, :address_result, :post_code_result, :cv2_result


      self.key_converter = key_converter.merge({
        "VPSTxId"        => :vps_tx_id,
        "TxAuthNo"       => :tx_auth_no,
        "SecurityKey"    => :security_key,
        "AVSCV2"         => :avs_cv2,
        "AddressResult"  => :address_result,
        "PostCodeResult" => :post_code_result,
        "CV2Result"      => :cv2_result
      })

      self.value_converter[:status]["NOTAUTHED"] = :not_authed
      self.value_converter = value_converter.merge({
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
      })

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
    end
  end
end
