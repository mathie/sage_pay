module ValidationMatchers
  def validates_the_presence_of(attribute, message = "can't be empty")
    address = address_factory(attribute => "")
    address.should_not be_valid
    address.errors.on(attribute).should == message
  end

  def does_not_validate_the_presence_of(attribute)
    address = address_factory(attribute => "")
    address.should be_valid
    address.errors.on(attribute).should be_nil
  end

  def validates_the_length_of(attribute, limits, message = "is invalid")
    if limits[:min]
      address = address_factory(attribute => 'a' * (limits[:min] - 1))
      address.should_not be_valid
      address.errors.on(attribute).should include(message)

      address = address_factory(attribute => 'a' * limits[:min])
      address.should be_valid
      address.errors.on(attribute).should be_nil

      address = address_factory(attribute => 'a' * (limits[:min] + 1))
      address.should be_valid
      address.errors.on(attribute).should be_nil
    end

    if limits[:max]
      address = address_factory(attribute => 'a' * (limits[:max] + 1))
      address.should_not be_valid
      address.errors.on(attribute).should include(message)

      address = address_factory(attribute => 'a' * limits[:max])
      address.should be_valid
      address.errors.on(attribute).should be_nil

      address = address_factory(attribute => 'a' * (limits[:max] - 1))
      address.should be_valid
      address.errors.on(attribute).should be_nil
    end
  end

  def validates_the_format_of(attribute, examples, message = "is invalid")
    (examples[:invalid] || []).each do |invalid|
      address = address_factory(attribute => invalid)
      address.should_not be_valid
      address.errors.on(attribute).should == message
    end

    (examples[:valid] || []).each do |valid|
      address = address_factory(attribute => valid)
      address.should be_valid
      address.errors.on(attribute).should be_nil
    end
  end
end
