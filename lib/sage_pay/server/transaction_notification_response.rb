module SagePay
  module Server
    class TransactionNotificationResponse
      include Validatable

      attr_accessor :status, :status_detail, :redirect_url

      validates_presence_of :status, :redirect_url
      validates_presence_of :status_detail,        :if => lambda { |response| !response.ok? }

      validates_length_of :redirect_url,  :maximum => 255
      validates_length_of :status_detail, :maximum => 255

      validates_inclusion_of :status, :allow_blank => true, :in => [ :ok, :invalid, :error ]

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def ok?
        status == :ok
      end

      def response
        response_params.map do |tuple|
          key, value = tuple
          "#{key}=#{value}"
        end.join("\r\n")
      end


      def response_params
        raise ArgumentError, "Invalid transaction registration options (see errors hash for details)" unless valid?

        # Mandatory parameters that we've already validated are present. Note
        # that the order of parameters is important (Status must be first!) so
        # we're using a list of lists this time around...
        params = [
          ["Status",      status.to_s.upcase],
          ["RedirectURL", redirect_url]
        ]

        # Optional parameters that are only inserted if they are present
        params << ['StatusDetail', status_detail] if present?(status_detail)

        # And return the completed hash
        params
      end

      private
      def present?(value)
        !blank?(value)
      end

      def blank?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end
  end
end
