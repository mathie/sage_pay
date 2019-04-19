module SagePay
  module Server
    class Command
      include ActiveModel::Validations

      class_attribute :tx_type, :vps_protocol

      self.vps_protocol = "2.23"

      attr_accessor :mode, :vendor, :vendor_tx_code

      validates_presence_of :vps_protocol, :mode, :tx_type, :vendor,
        :vendor_tx_code

      validates_length_of :vps_protocol,     :is      => 4
      validates_length_of :vendor,           :maximum => 15
      validates_length_of :vendor_tx_code,   :maximum => 40

      validates_inclusion_of :mode, :allow_blank => true, :in => [ :showpost, :simulator, :test, :live ]

      def self.decimal_accessor(*attrs)
        attrs.each do |attr|
          attr_reader attr
          define_method("#{attr}=") do |value|
            instance_variable_set("@#{attr}", value.blank? ? nil : BigDecimal(value.to_s))
          end
        end
      end

      def initialize(attributes = {})
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
        when :showpost
          "https://test.sagepay.com/showpost/showpost.asp?Service=#{simulator_service}"
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

        if parsed_uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = '/etc/ssl/certs/ca-certificates.crt' if File.exists?('/etc/ssl/certs/ca-certificates.crt')
        end

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
          raise RuntimeError, "I guess SagePay doesn't like us today: #{response.inspect}"
        end
      end
    end
  end
end
