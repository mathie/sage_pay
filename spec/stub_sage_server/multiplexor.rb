# SagePay multiplexor is a proxy to allow multiple apps in the same ip address
# to interact seemlessly with SagePay gateway, so that testing can be done when no VCR
# or mocking are required.

require 'sinatra'
require 'awesome_print'

require File.expand_path("../uri_fixups.rb", __FILE__)

puts "  Initializing sage multiplexor..."

multiplexor_config_path = File.expand_path("../multiplexor_config.rb", __FILE__)

puts "  Loading configuration file in #{multiplexor_config_path}"

example_file = <<-EXAMPLE_FILE
  # Example multiplexor config file
  # spec/stub_sage_server/multiplexor_config.rb

  # Smart proxy acts like VCR and redirects/routes only to the original requester, NO multicast
  SAGE_MULTIPLEXOR_SMART_PROXY = true

  # List the urls you wish to multicast to in here, like the following example:
  # <address_to_multicast_to> => options[Hash]
  # active: true/false to disable the multicast to that address

  SAGE_MULTIPLEXOR_ADDRESSES = {
    "http://localhost:3000/sage_pay/notification" => {active: true},
    "http://192.168.0.1:8080/sage_pay/notification" => {active: false}
  }
EXAMPLE_FILE

unless File.exists? multiplexor_config_path
  puts "  SagePay multiplexor config file not found... creating example file, don't forget to customize it"
  puts example_file
  File.open(multiplexor_config_path, 'w') {|f| f.puts example_file}
end

require multiplexor_config_path

# Parse multicast string addresses to URIs
address_mapping = {}
SAGE_MULTIPLEXOR_ADDRESSES.each do |address, options|
  address_mapping.store URI.parse(address), options
end

# URLs config (listen here)
port_to_use = 80
gateway_side_url = '/sage_pay/notification' # Sage gateway sends here
application_side_url = '/sage_pay/gateway' # Apps sends here
gateway_url = "<sagepaygatewayurl>" # Apps sends here
set :port, port_to_use

puts "  Listening in port #{port_to_use}"
puts "  Gateway-side url is #{gateway_side_url}"
puts "  App-side url is #{application_side_url}"

# Show which addresses are in use for multicasting
puts "  Multicasting to the following:"
address_mapping.each do |address, options|
  puts "  - #{address}" if options[:active]
end

class Multiplexor

  # The params that requests/responses both share to match
  def self.matching_params
    %W(VendorTxCode)
  end

  #def self.param_substitution
  #  {
  #      "NotificationURL" => '<replacement>'
  #  }
  #end

  attr_accessor :router_mapping # [requester_address1, requester_address2] => []
  attr_accessor :matching_params
  attr_accessor :smart

  def initialize(smart_proxy = true, matching_parameters = nil)
    @smart = smart_proxy
    @matching_params = matching_parameters || Multiplexor.matching_params
  end

  def store(address)
    router_mapping
  end

  def compare()

  end

  def smart?
    @smart
  end

  def process_redirection(params)
    ap params
    # A SagePay notification?
    unless params["VendorTxCode"]
      puts '  WARNING: Received post may not be a valid sagepay notification'
    end

  end

  def multicast_to(addresses, params)

  end

end

multiplexor = Multiplexor.new

# Receive notification posts to this URL
post gateway_side_url do
  puts "  Receiving from gateway:"
  #receiveing_addresses = process_redirection(params)
  #multicast_to receiveing_addresses, params
  puts "-----------------------------------"
end

get application_side_url do
  puts "  Receiving from app:"
  ap params
  ap request
  #receiveing addresses = process_redirection(params)
  #multicast_to receiveing_addresses, params
  puts "-----------------------------------"
end
