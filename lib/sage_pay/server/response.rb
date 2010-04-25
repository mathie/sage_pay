module SagePay
  module Server
    class Response
      class_inheritable_hash :key_converter, :value_converter, :instance_writer => false

      self.key_converter = {
        "VPSProtocol"  => :vps_protocol,
        "Status"       => :status,
        "StatusDetail" => :status_detail,
      }

      self.value_converter = {
        :status => {
          "OK"        => :ok,
          "MALFORMED" => :malformed,
          "INVALID"   => :invalid,
          "ERROR"     => :error
        }
      }

      attr_reader :vps_protocol, :status, :status_detail

      def self.from_response_body(response_body)
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
    end
  end
end
