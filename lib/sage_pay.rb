require 'validatable'

module SagePay
  VERSION = '0.1.0'
end

require 'validatable-ext'

require 'sage_pay/server/address'
require 'sage_pay/server/transaction_registration'
require 'sage_pay/server'
