Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.6'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'sage_pay'
  s.version           = '0.2.13'
  s.date              = '2010-08-15'
  s.rubyforge_project = 'sage_pay'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Ruby implementation of the SagePay payment gateway protocol."
  s.description = <<-DESCRIPTION
This is a Ruby library for integrating with SagePay. SagePay is a payment
gateway for accepting credit card payments through your web app.
  DESCRIPTION

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Graeme Mathieson"]
  s.email    = 'mathie@woss.name'
  s.homepage = 'http://github.com/mathie/sage_pay'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('activesupport', [">= 2.3.8"])
  s.add_dependency('validatable',   [">= 1.6.7"])
  s.add_dependency('uuid',          [">= 2.3.0"])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('rspec')

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    Gemfile
    Gemfile.lock
    LICENSE
    README.md
    Rakefile
    TODO
    lib/sage_pay.rb
    lib/sage_pay/server.rb
    lib/sage_pay/server/abort.rb
    lib/sage_pay/server/address.rb
    lib/sage_pay/server/authorise.rb
    lib/sage_pay/server/cancel.rb
    lib/sage_pay/server/command.rb
    lib/sage_pay/server/notification.rb
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
    lib/sage_pay/server/transaction_code.rb
    lib/sage_pay/uri_fixups.rb
    lib/validatable-ext.rb
    lib/validations/validates_inclusion_of.rb
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
    spec/sage_pay_spec.rb
    spec/spec_helper.rb
    spec/support/factories.rb
    spec/support/integration.rb
    spec/support/validation_matchers.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
