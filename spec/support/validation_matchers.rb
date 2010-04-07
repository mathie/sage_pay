module ValidationMatchers
  def validates_the_presence_of(model_name, attribute, message = "can't be empty")
    model = model_factory(model_name, attribute => "")
    model.should_not be_valid
    model.errors.on(attribute).should include(message)
  end

  def does_not_require_the_presence_of(model_name, attribute)
    model = model_factory(model_name, attribute => "")
    model.should be_valid
    model.errors.on(attribute).should be_nil
  end

  def validates_the_length_of(model_name, attribute, limits, message = "is invalid")
    if limits[:min]
      model = model_factory(model_name, attribute => 'a' * (limits[:min] - 1))
      model.should_not be_valid
      model.errors.on(attribute).should include(message)

      model = model_factory(model_name, attribute => 'a' * limits[:min])
      model.should be_valid
      model.errors.on(attribute).should be_nil

      model = model_factory(model_name, attribute => 'a' * (limits[:min] + 1))
      model.should be_valid
      model.errors.on(attribute).should be_nil
    end

    if limits[:max]
      model = model_factory(model_name, attribute => 'a' * (limits[:max] - 1))
      model.should be_valid
      model.errors.on(attribute).should be_nil

      model = model_factory(model_name, attribute => 'a' * limits[:max])
      model.should be_valid
      model.errors.on(attribute).should be_nil

      model = model_factory(model_name, attribute => 'a' * (limits[:max] + 1))
      model.should_not be_valid
      model.errors.on(attribute).should include(message)
    end

    if limits[:exactly]
      model = model_factory(model_name, attribute => 'a' * (limits[:exactly] - 1))
      model.should_not be_valid
      model.errors.on(attribute).should include(message)

      model = model_factory(model_name, attribute => 'a' * limits[:exactly])
      model.should be_valid
      model.errors.on(attribute).should be_nil

      model = model_factory(model_name, attribute => 'a' * (limits[:exactly] + 1))
      model.should_not be_valid
      model.errors.on(attribute).should include(message)
    end
  end

  def validates_the_format_of(model_name, attribute, examples, message = "is invalid")
    (examples[:invalid] || []).each do |invalid|
      model = model_factory(model_name, attribute => invalid)
      model.should_not be_valid
      model.errors.on(attribute).should == message
    end

    (examples[:valid] || []).each do |valid|
      model = model_factory(model_name, attribute => valid)
      model.should be_valid
      model.errors.on(attribute).should be_nil
    end
  end
end
