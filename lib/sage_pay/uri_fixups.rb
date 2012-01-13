# Need to not fail when uri contains curly braces
# This overrides the DEFAULT_PARSER with the UNRESERVED key, including '{' and '}'
# TODO: Override the DEFAULT_PARSER completely so that a new Parser object is not created every time
module URI
  def self.parse(uri)
    URI::Parser.new(:UNRESERVED => URI::REGEXP::PATTERN::UNRESERVED + "\{\}").parse(uri)
  end
end
