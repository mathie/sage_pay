module Factories
  include SagePay::Server

  def model_factory(model_name, overrides = {})
    send("#{model_name}_factory", overrides)
  end

  def address_factory(overrides = {})
    # Data provided courtesy of Faker
    defaults = {
      :first_names => "Aryanna",
      :surname     => "Larkin",
      :address_1   => "19313 Cristian Parks",
      :city        => "Lurlineport",
      :post_code   => "UI62 7BJ",
      :country     => "GB"
    }
    Address.new(defaults.merge(overrides))
  end

  def registration_factory(overrides = {})
    defaults = {
      :mode             => :test,
      :tx_type          => :payment,
      :vendor           => "BobTheBuilder",
      :vendor_tx_code   => "random-transaction-id",
      :amount           => BigDecimal("35.49"),
      :currency         => "GBP",
      :description      => "Factory payment",
      :notification_url => "http://test.host/notification",
      :billing_address  => address_factory,
      :delivery_address => address_factory
    }
    Registration.new(defaults.merge(overrides))
  end

  def registration_response_factory(overrides = {})
    defaults = {
    }
    RegistrationResponse.new(defaults.merge(overrides))
  end

  def notification_factory(overrides = {})
    defaults = {
    }
    Notification.new(defaults.merge(overrides))
  end

  def notification_response_factory(overrides = {})
    defaults = {
      :status        => :ok,
      :status_detail => "A-OK!",
      :redirect_url  => "http://test.host/redirect"
    }
    NotificationResponse.new(defaults.merge(overrides))
  end

end
