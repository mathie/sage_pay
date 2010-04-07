require 'rubygems'
require 'spec/autorun'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sage_pay'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  config.include(Factories)
  config.include(ValidationMatchers)
end
