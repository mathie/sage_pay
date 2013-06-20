require 'spec_helper'

describe URI do
  it 'considers a URL with curly braces in a query string value to be valid' do
    lambda {
      URI.parse("http://example.com/path?query={abcdef}")
    }.should_not raise_error
  end
end
