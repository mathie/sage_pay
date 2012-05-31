require 'rubygems'
require 'colorize'
require 'awesome_print'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sage_pay'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  ### Custom settings could also be in .rspec file
  config.color_enabled = true
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  #config.formatter = :documentation # :progress, :html, :textmate

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # This allows you to tag an exaple with :focus to make it run with Guard
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.include(Factories)

  config.before(:suite) do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

end

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
