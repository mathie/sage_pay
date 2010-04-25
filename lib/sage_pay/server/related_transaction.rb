module SagePay
  module Server
    class RelatedTransaction
      include Validatable

      attr_accessor :vps_tx_id, :vendor_tx_code, :security_key, :tx_auth_no

      validates_presence_of :vps_tx_id, :vendor_tx_code, :security_key, :tx_auth_no

      validates_length_of :vps_tx_id,        :is      => 38
      validates_length_of :vendor_tx_code,   :maximum => 40
      validates_length_of :security_key,     :is      => 10

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def post_params
        {
          "RelatedVPSTxId"      => vps_tx_id,
          "RelatedVendorTxCode" => vendor_tx_code,
          "RelatedSecurityKey"  => security_key,
          "RelatedTxAuthNo"     => tx_auth_no,
        }
      end
    end
  end
end
