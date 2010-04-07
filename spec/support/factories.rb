module Factories
  def address_factory(overrides = {})
    # Data provided courtesy of Faker
    address = SagePay::Server::Address.new :first_names => "Aryanna", :surname => "Larkin",
      :address_1 => "19313 Cristian Parks", :city => "Lurlineport",
      :post_code => "UI62 7BJ", :country => "GB"

    overrides.each do |k,v|
      address.send("#{k}=", v)
    end

    address
  end
end
