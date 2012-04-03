require 'sinatra'
require 'awesome_print'
require 'yaml'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
#require 'colorize' # gem install colorize

require File.expand_path("../uri_fixups.rb", __FILE__)

puts "Initiating SagePay Notification capturer..."
port_to_use = 80
notification_url = '/sage_pay/notification'

set :port, port_to_use
puts "  Listening in port #{port_to_use}"
puts "  Listening for posts in #{notification_url}"

def process_filename_from(params)
  ap params
  # Ensure is a SagePay notification
  if params["VPSProtocol"]

    tx_type = params["TxType"].try(:downcase)
    vendor_tx_code = params["VendorTxCode"].try(:gsub, '-', '_').try(:downcase)
    status = params["Status"].try(:downcase)

    if tx_type || status || vendor_tx_code # any of them is ok
      file_name = "#{tx_type}_#{status}_#{vendor_tx_code}"
    else
      file_name = Time.now.strftime "sagepay_%Y%m%d_%H%M%S"
    end

  else
    file_name = Time.now.strftime "invalid_%Y%m%d_%H%M%S"
    puts '  WARNING: Received post may not be a valid sagepay notification'
  end
  file_name
end

def capture_response(file_name, params)
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

  # Process a descriptive filename
  file_name = process_filename_from params

  # Write to file in any case to avoid lossing information
  capture_response file_name, params
  puts "--------------------------------"
end
