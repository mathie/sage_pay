module SagePay
  module Server
    class << self
      attr_accessor :default_registration_options
    end
    # NOTE: Expected to be something along the lines of:
    #
    #     SagePay::Server.default_registration_options = {
    #       :mode => :live,
    #       :vendor => "rubaidh",
    #       :notification_url => "http://test.host/notification"
    #     }
    #
    # ... which you'll want to stick in config/initializers/sage_pay.rb or one
    # of your environment files, if you're doing this with a Rails app.
    self.default_registration_options = {}

    # The notification URL is only relevant to registration options, but the
    # rest are relevant to all requests.
    # FIXME: This should be Hash#only instead of Hash#except!
    def self.default_options
      default_registration_options.except(:notification_url, :profile)
    end

    def self.default_transaction_options
      default_options.merge({
        :vendor_tx_code => TransactionCode.random
      })
    end

    def self.related_transaction(attributes = {})
      SagePay::Server::RelatedTransaction.new(attributes)
    end

    def self.payment(attributes = {})
      registration({ :tx_type => :payment }.merge(attributes))
    end

    def self.deferred(attributes = {})
      registration({ :tx_type => :deferred }.merge(attributes))
    end

    def self.authenticate(attributes = {})
      registration({ :tx_type => :authenticate }.merge(attributes))
    end

    def self.registration(attributes)
      defaults = {
        :vendor_tx_code   => TransactionCode.random,
        :delivery_address => attributes[:billing_address]
      }.merge(default_registration_options)

      SagePay::Server::Registration.new(defaults.merge(attributes))
    end

    def self.release(attributes = {})
      SagePay::Server::Release.new(default_options.merge(attributes))
    end

    def self.abort(attributes = {})
      SagePay::Server::Abort.new(default_options.merge(attributes))
    end

    def self.refund(attributes = {})
      SagePay::Server::Refund.new(default_transaction_options.merge(attributes))
    end

    def self.authorise(attributes = {})
      SagePay::Server::Authorise.new(default_transaction_options.merge(attributes))
    end

    def self.cancel(attributes = {})
      SagePay::Server::Cancel.new(default_options.merge(attributes))
    end

    def self.repeat(attributes = {})
      SagePay::Server::Repeat.new(default_transaction_options.merge(attributes))
    end
  end
end
