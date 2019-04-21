module ValidationMatchers
  def validates_the_presence_of(model_name, attribute, message = "can't be empty")
    model = model_factory(model_name, attribute => "")
    expect(model).to_not be_valid
    expect(model.errors[attribute]).to include(message)
  end

  def does_not_require_the_presence_of(model_name, attribute)
    model = model_factory(model_name, attribute => "")
    expect(model).to be_valid
    expect(model.errors[attribute]).to be_empty
  end

  def validates_the_length_of(model_name, attribute, limits, message = "is invalid")
    if limits[:min]
      model = model_factory(model_name, attribute => 'a' * (limits[:min] - 1))
      model.should_not be_valid
      model.errors[attribute].should include(message)

      model = model_factory(model_name, attribute => 'a' * limits[:min])
      model.should be_valid
      model.errors[attribute].should be_empty

      model = model_factory(model_name, attribute => 'a' * (limits[:min] + 1))
      model.should be_valid
      model.errors[attribute].should be_empty
    end

    if limits[:max]
      model = model_factory(model_name, attribute => 'a' * (limits[:max] - 1))
      model.should be_valid
      model.errors[attribute].should be_empty

      model = model_factory(model_name, attribute => 'a' * limits[:max])
      model.should be_valid
      model.errors[attribute].should be_empty

      model = model_factory(model_name, attribute => 'a' * (limits[:max] + 1))
      model.should_not be_valid
      model.errors[attribute].should include(message)
    end

    if limits[:exactly]
      model = model_factory(model_name, attribute => 'a' * (limits[:exactly] - 1))
      model.should_not be_valid
      model.errors[attribute].should include(message)

      model = model_factory(model_name, attribute => 'a' * limits[:exactly])
      model.should be_valid
      model.errors[attribute].should be_empty

      model = model_factory(model_name, attribute => 'a' * (limits[:exactly] + 1))
      model.should_not be_valid
      model.errors[attribute].should include(message)
    end
  end

  def validates_the_format_of(model_name, attribute, examples, message = "is invalid")
    (examples[:invalid] || []).each do |invalid|
      model = model_factory(model_name, attribute => invalid)
      model.should_not be_valid
      model.errors[attribute].should include(message)
    end

    (examples[:valid] || []).each do |valid|
      model = model_factory(model_name, attribute => valid)
      model.should be_valid
      model.errors[attribute].should be_empty
    end
  end
end
