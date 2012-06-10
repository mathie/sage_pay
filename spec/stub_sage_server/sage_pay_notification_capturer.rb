require 'sinatra'
require 'awesome_print'
require 'yaml'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
#require 'colorize' # gem install colorize

require File.expand_path("../../support/vendor_config.rb", __FILE__)
require File.expand_path("../uri_fixups.rb", __FILE__)
#require '/Users/spare/GitHub/sage_pay_jairo/spec/stub_sage_server/uri_fixups.rb'
#require File.expand_path("../../../lib/sage_pay.rb", __FILE__)

$: << File.join(File.dirname(__FILE__), '../..', 'lib')
require 'sage_pay'

puts "Initiating SagePay Notification capturer..."

# Configuration for sage_pay

SagePay::Server.default_registration_options = {
    :mode => :test,
    :vendor => SIMULATOR_VENDOR_NAME,
    :notification_url => SIMULATOR_NOTIFICATION_URL
}

puts "  Using SIMULATOR_VENDOR_NAME #{SIMULATOR_VENDOR_NAME}"
puts "  Using SIMULATOR_NOTIFICATION_URL #{SIMULATOR_NOTIFICATION_URL}"

# Listen config

port_to_use = 80
notification_url = '/sage_pay/notification'
set :port, port_to_use
puts "  Listening in port #{port_to_use}"
puts "  Listening for posts in #{notification_url}"

# Given a request with some params, compute a filename for storing the request
def process_filename_from(params)
  # Ensure is a SagePay notification
  if params["VPSProtocol"]

    tx_type = params["TxType"].try(:downcase)
    #vendor_tx_code = params["VendorTxCode"].try(:gsub, '-', '_').try(:downcase)
    status = params["Status"].try(:downcase)

    if tx_type || status # any of them is ok
      file_name = "#{tx_type}_#{status}"
    else
      file_name = Time.now.strftime "sagepay_%Y%m%d_%H%M%S"
    end

  else
    file_name = Time.now.strftime "invalid_%Y%m%d_%H%M%S"
    puts '  WARNING: Received post may not be a valid sagepay notification'
  end
  file_name
end

def capture_response_in_file(file_name, params)
  full_path = File.expand_path("../responses/#{file_name}.yml", __FILE__)
  yaml_obj = YAML::dump(params)
  File.open(full_path, 'w') do |f|
    f.write yaml_obj
  end
  puts "  Capturing response in #{full_path}"
  puts "  File name is #{file_name}"
end


# Receive posts to this URL, must be the same as the notification url used by
post notification_url do
  puts '  Receiving notification:'
  puts '  params are: '
  ap params

  # Process a descriptive filename
  file_name = process_filename_from params

  # Capture the params
  capture_response_in_file file_name, params

  # Generate response given the last action

  puts '  generating notification object to generate Ok response...'
  name = File.expand_path("../last_security_key.yml", __FILE__)
  registration_response = YAML::load(File.open(name))
  # Print the response to be issued to the gateway
  ap registration_response

  # Render the reply message in the required format
  reply_message = generate_reply(SIMULATOR_VENDOR_NAME, registration_response.security_key, params)
  puts "  replying with:"
  ap reply_message
  puts "----------------------------------------"
  
  # Send the reply: OK
  reply_message
end

# Based on the last transaction, generate the reply
def generate_reply(vendor, security_key, params)
  notification = SagePay::Server::Notification.from_params(params) do
    SagePay::Server::SignatureVerificationDetails.new(vendor, security_key)
  end
  notification.response("http://google.com?q=status_#{}") # redirects here if ok!
end
