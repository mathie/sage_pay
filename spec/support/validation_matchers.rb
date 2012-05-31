module ValidationMatchers
  def validates_the_format_of(model_name, attribute, examples, message = "is invalid")
    (examples[:invalid] || []).each do |invalid|
      model = model_factory(model_name, attribute => invalid)
      model.should_not be_valid
      model.errors[attribute][0].should == message
    end

    (examples[:valid] || []).each do |valid|
      model = model_factory(model_name, attribute => valid)
      model.should be_valid
      model.errors[attribute][0].should be_nil
    end
  end
end
