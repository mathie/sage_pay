module SagePay
  module Server
    class TransactionRegistrationResponse
      attr_reader :vps_protocol, :status, :status_detail

      def self.from_response_body(response_body)
        key_converter = {
          "VPSProtocol"  => :vps_protocol,
          "Status"       => :status,
          "StatusDetail" => :status_detail,
          "VPSTxId"      => :transaction_id,
          "SecurityKey"  => :security_key,
          "NextURL"      => :next_url
        }

        value_converter = {
          :status => {
            "OK"        => :ok,
            "MALFORMED" => :malformed,
            "INVALID"   => :invalid,
            "ERROR"     => :error
          }
        }

        attributes = {}
        response_body.each_line do |line|
          key, value = line.split('=', 2)
          unless key.nil? || value.nil?
            value = value.chomp

            converted_key = key_converter[key]
            converted_value = value_converter[converted_key].nil? ? value : value_converter[converted_key][value]

            attributes[converted_key] = converted_value
          end
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

      def failed?
        !ok?
      end

      def invalid?
        status == :invalid
      end

      def malformed?
        status == :malformed
      end

      def error?
        status == :error
      end

      def transaction_id
        if ok?
          @transaction_id
        else
          raise RuntimeError, "Unable to retrieve the transaction id as the status was not OK."
        end
      end

      def security_key
        if ok?
          @security_key
        else
          raise RuntimeError, "Unable to retrieve the security key as the status was not OK."
        end
      end

      def next_url
        if ok?
          @next_url
        else
          raise RuntimeError, "Unable to retrieve the next URL as the status was not OK."
        end
      end
    end
  end
end
