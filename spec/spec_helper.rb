require 'rubygems'
require 'spec/autorun'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sage_pay'

Spec::Runner.configure do |config|
end
