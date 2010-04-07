module Validatable
  class ValidatesInclusionOf < ValidationBase #:nodoc:
    option :allow_blank
    required_option :in
    
    def message(instance)
      super || "is not in the list"
    end
    
    def valid?(instance)
      valid = true
      value = instance.send(self.attribute)
      
      if value.nil? || value.empty?
        return true if allow_blank
        value = ""
      end

      @in.include?(value)
    end
  end
end