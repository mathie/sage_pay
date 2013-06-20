require 'rubygems'

if ENV['COVERAGE'] && RUBY_VERSION >= '1.9'
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
  end
end

if RUBY_VERSION >= '1.9'
  require 'coveralls'
  Coveralls.wear!
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sage_pay'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include(Factories)
  config.include(ValidationMatchers)
end
