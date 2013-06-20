require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

task :default => :spec

RSpec::Core::RakeTask.new

begin
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  # Never mind, no rdoc for us, then.
end

desc "Open an irb session preloaded with this library"
task :console do
  ruby "-S irb -rubygems -Ilib -r ./lib/sage_pay.rb -r ./spec/support/factories.rb"
end
