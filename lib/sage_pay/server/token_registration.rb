module SagePay
  module Server
    class TokenRegistration < Command

      self.tx_type = :token
      attr_accessor :currency, :notification_url

      validates_presence_of :notification_url

      validates_length_of :currency,         :is      => 3
      validates_length_of :notification_url, :maximum => 255


      def post_params
        params = super.merge({
          "Currency"         => currency,
          "NotificationURL"  => notification_url,
        })
        params
      end

      def response_from_response_body(response_body)
        # FIXME: Since RepeatResponse is being shared for repeats and
        # authorisations, it should probably be renamed.
        Response.from_response_body(response_body)
      end

      def live_service
        "token"
      end

      # Does not exist, but anyways put here just in case
      def simulator_service
        "token"
      end
      
    end
  end
end
