# Need to not fail when uri contains curly brackets
# This overrides the DEFAULT_PARSER with the UNRESERVED key, including '{' and '}'
module URI
  def self.parse(uri)
    URI::Parser.new(:UNRESERVED => "-_.!~*'()#{URI::REGEXP::PATTERN::ALNUM}\{\}").parse(uri)
  end
end
