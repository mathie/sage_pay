module SagePay
  module Server
    class TransactionRegistrationResponse
      include Validatable

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def self.from_response_body(response_body)
        new
      end
    end
  end
end
