begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

# [Steve A.] install_tasks is required to be launched before engine.rake, due
# to a current conflict between Bundler and/or guard-rspec.
#
# See:
# - Bundler: https://github.com/bundler/bundler/issues/3205
# - guard-rspec: https://github.com/guard/guard-rspec/issues/258
#
#Bundler::GemHelper.install_tasks

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GogglesCore5'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
end

task default: :spec

# Old version: (Rails 3)
#
# APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
# load 'rails/tasks/engine.rake'#
#
# begin
  # require 'rdoc/task'
# rescue LoadError
  # require 'rdoc/rdoc'
  # require 'rake/rdoctask'
  # RDoc::Task = Rake::RDocTask
# end
#
# RDoc::Task.new(:rdoc) do |rdoc|
  # rdoc.rdoc_dir = 'rdoc'
  # rdoc.title    = 'GogglesCore'
  # rdoc.options << '--line-numbers'
  # rdoc.rdoc_files.include('README.rdoc')
  # rdoc.rdoc_files.include('lib/**/*.rb')
# end
#
#
# Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }
#
# require 'rspec/core'
# require 'rspec/core/rake_task'
#
# desc "Run all specs in spec directory (excluding plugin specs)"
# RSpec::Core::RakeTask.new( spec: 'app:db:test:prepare' )
#
# task default: :spec
