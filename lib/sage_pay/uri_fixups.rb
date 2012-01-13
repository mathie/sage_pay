# Need to not fail when uri contains curly braces
# This overrides the DEFAULT_PARSER with the UNRESERVED key, including '{' and '}'
# DEFAULT_PARSER is used everywhere, so its better to override it once
module URI
  remove_const :DEFAULT_PARSER
  unreserved = REGEXP::PATTERN::UNRESERVED
  DEFAULT_PARSER = Parser.new(:UNRESERVED => unreserved + "\{\}")
end
