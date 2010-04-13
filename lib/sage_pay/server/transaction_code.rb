module SagePay
  module Server
    class TransactionCode
      def self.random
        new.random
      end

      def random
        uuid.generate
      end

      protected
      def uuid
        @uuid ||= UUID.new
      end
    end
  end
end