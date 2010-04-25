module SagePay
  module Server
    class Command
      include Validatable

      attr_reader :vps_protocol
      attr_accessor :mode, :tx_type, :vendor, :vendor_tx_code

      validates_presence_of :vps_protocol, :mode, :tx_type, :vendor,
        :vendor_tx_code

      validates_length_of :vps_protocol,     :is      => 4
      validates_length_of :vendor,           :maximum => 15
      validates_length_of :vendor_tx_code,   :maximum => 40

      validates_inclusion_of :mode, :allow_blank => true, :in => [ :simulator, :test, :live ]

      def initialize(attributes = {})
        @vps_protocol = "2.23"

        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def run!
        @response ||= handle_response(post)
      end

      def live_service
        raise NotImplementedError, "Subclass of command implement live_service with tail of the URL used for that command in the test & live systems."
      end

      def simulator_service
        raise NotImplementedError, "Subclass of command implement simulator_service with tail of the URL used for that command in the simulator."
      end

      def url
        case mode
        when :simulator
          "https://test.sagepay.com/simulator/VSPServerGateway.asp?Service=#{simulator_service}"
        when :test
          "https://test.sagepay.com/gateway/service/#{live_service}.vsp"
        when :live
          "https://live.sagepay.com/gateway/service/#{live_service}.vsp"
        else
          raise ArgumentError, "Invalid transaction mode"
        end
      end

      def post_params
        raise ArgumentError, "Invalid transaction registration options (see errors hash for details)" unless valid?

        {
          "VPSProtocol"        => vps_protocol,
          "TxType"             => tx_type.to_s.upcase,
          "Vendor"             => vendor,
          "VendorTxCode"       => vendor_tx_code,
        }
      end

      def response_from_response_body(response_body)
        Response.from_response_body(response_body)
      end

      private
      def post
        parsed_uri = URI.parse(url)
        request = Net::HTTP::Post.new(parsed_uri.request_uri)
        request.form_data = post_params

        http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
        http.use_ssl = true if parsed_uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      def handle_response(response)
        case response.code.to_i
        when 200
          response_from_response_body(response.body)
        else
          # FIXME: custom error response would be nice.
          raise RuntimeError, "I guess SagePay doesn't like us today."
        end
      end

      def present?(value)
        !blank?(value)
      end

      def blank?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end
  end
end
