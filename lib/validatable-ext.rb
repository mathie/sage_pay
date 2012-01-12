require 'validatable'
require 'validations/validates_inclusion_of'

module Validatable
  module Macros
    # call-seq: validates_inclusion_of(*args)
    #
    # Encapsulates the pattern of wanting to validate that an attribute is is in a list. Example:
    # 
    #   class Person
    #     include Validatable
    #     validates_inclusion_of :operating_system, :in => ["Mac OS X", "Linux", "Windows"]
    #   end
    #
    # Configuration options:
    # 
    #     * in - a list of acceptable answers
    #     * after_validate - A block that executes following the run of a validation
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_inclusion_of(*args)
      add_validations(args, ValidatesInclusionOf)
    end
  end
end
