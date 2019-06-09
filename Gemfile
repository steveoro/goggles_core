# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in goggles_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'actionview', '~> 5.1.6.2'
gem 'haml-rails', '~> 2'

# jquery-rails is used by the dummy application
gem 'jquery-rails'

gem 'amistad', git: 'https://github.com/fasar-sw/amistad.git', branch: 'rails5' # [Steve] Customized version. For Facebook-like friendship management

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

group :development do
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-shell'
  gem 'guard-spring'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
end

group :development, :test do
  gem 'bullet'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'ffaker'                  # Adds dummy names & fixture generator
  gem 'letter_opener'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rubocop', require: false # For style checking
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'codeclimate-test-reporter', require: nil # [Steve, 20140321] CI/Test coverage via local test run
  gem 'rails_best_practices'
  gem 'simplecov'
end
