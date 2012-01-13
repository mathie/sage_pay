require 'rubygems'
require 'spec/autorun'
require 'colorize'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sage_pay'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

puts "Loading vendor configuration...".green
errors = []
errors << "TEST_VENDOR_NAME is not set" unless defined? TEST_VENDOR_NAME
errors << "TEST_NOTIFICATION_URL is not set" unless defined? TEST_NOTIFICATION_URL
errors << "SIMULATOR_VENDOR_NAME is not set" unless defined? SIMULATOR_VENDOR_NAME
errors << "SIMULATOR_NOTIFICATION_URL is not set" unless defined? SIMULATOR_NOTIFICATION_URL

unless errors.empty?
  puts "config file below, place custom settings in spec/support/vendor_config.rb as below>".cyan
  example_file = <<EXAMPLE_FILE

  #spec/support/vendor_config.rb

  TEST_VENDOR_NAME = "testvendor"
  TEST_NOTIFICATION_URL= "http://test.host/notification"

  SIMULATOR_VENDOR_NAME = "your_simulator_account_vendor_name"
  SIMULATOR_NOTIFICATION_URL= "your_simulator_site_notification_url"

EXAMPLE_FILE
  puts example_file.light_white

  puts errors.join("\n").red

  raise "Vendor configuration not set properly, see the above example file"
end

Spec::Runner.configure do |config|
  config.include(Factories)
  config.include(ValidationMatchers)
end
