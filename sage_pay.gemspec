$: << 'lib'
require 'sage_pay/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_ruby_version = '>= 1.9.2'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.6'

  s.name              = 'sage_pay'
  s.version           = SagePay::VERSION
  s.date              = '2012-07-21'
  s.rubyforge_project = 'sage_pay'

  s.summary     = "Ruby implementation of the SagePay payment gateway protocol."
  s.description = <<-DESCRIPTION
This is a Ruby library for integrating with SagePay. SagePay is a payment
gateway for accepting credit card payments through your web app.
  DESCRIPTION

  s.authors  = ["Graeme Mathieson"]
  s.email    = 'mathie@woss.name'
  s.homepage = 'http://github.com/mathie/sage_pay'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency('activesupport', [">= 3.1.3"])
  s.add_dependency('activemodel',   [">= 3.1.0"])
  s.add_dependency('uuid',          [">= 2.3.0"])
  s.add_dependency('i18n',          [">= 0.6.0"])

  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')

  s.files = %w[
    .rspec
    CHANGELOG.md
    Gemfile
    LICENSE
    README.md
    Rakefile
    TODO
    config/locales/en.yml
    lib/sage_pay.rb
    lib/sage_pay/locale_initializer.rb
    lib/sage_pay/server.rb
    lib/sage_pay/server/abort.rb
    lib/sage_pay/server/address.rb
    lib/sage_pay/server/authorise.rb
    lib/sage_pay/server/cancel.rb
    lib/sage_pay/server/command.rb
    lib/sage_pay/server/notification.rb
    lib/sage_pay/server/notification_params_converter.rb
    lib/sage_pay/server/notification_response.rb
    lib/sage_pay/server/refund.rb
    lib/sage_pay/server/refund_response.rb
    lib/sage_pay/server/registration.rb
    lib/sage_pay/server/registration_response.rb
    lib/sage_pay/server/related_transaction.rb
    lib/sage_pay/server/release.rb
    lib/sage_pay/server/repeat.rb
    lib/sage_pay/server/repeat_response.rb
    lib/sage_pay/server/response.rb
    lib/sage_pay/server/signature_verification_details.rb
    lib/sage_pay/server/signature_verifier.rb
    lib/sage_pay/server/transaction_code.rb
    lib/sage_pay/uri_fixups.rb
    lib/sage_pay/validators.rb
    lib/sage_pay/version.rb
    sage_pay.gemspec
    spec/integration/sage_pay/server_spec.rb
    spec/sage_pay/server/address_spec.rb
    spec/sage_pay/server/notification_response_spec.rb
    spec/sage_pay/server/notification_spec.rb
    spec/sage_pay/server/registration_response_spec.rb
    spec/sage_pay/server/registration_spec.rb
    spec/sage_pay/server/signature_verification_details_spec.rb
    spec/sage_pay/server/transaction_code_spec.rb
    spec/sage_pay/server_spec.rb
    spec/sage_pay/uri_spec.rb
    spec/sage_pay_spec.rb
    spec/spec_helper.rb
    spec/support/factories.rb
    spec/support/integration.rb
    spec/support/validation_matchers.rb
  ]

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
