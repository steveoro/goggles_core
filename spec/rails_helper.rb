# [Steve] Test coverage integrated on SimpleCov, with local HTML-file reports
# (Remember to exclude /coverage sub-dir from git repo)
require 'simplecov'
SimpleCov.start 'rails'
puts "SimpleCov+CodeClimate::TestReporter required and started."


# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'devise' # note: require 'devise' after require 'rspec/rails' (this allows to use devise test helpers)
require 'factory_bot_rails'

# DatabaseCleaner (when used) require goes here:
# require 'database_cleaner'


# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Load support files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')
Dir[ File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb') ].each { |f| require f }

Rails.backtrace_cleaner.remove_silencers!

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!


RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # [Steve, 20140226] Add helpers to get Devise working with RSpec
  config.include( Devise::Test::ControllerHelpers, type: :controller )
  config.include( Devise::Test::ControllerHelpers, type: :view )
  config.include( Devise::TestHelpers, type: :features )
  # [Steve, 20140226] Add other custom helpers.
  # (Use #include to access the methods at the instance level: inside examples.)
  # (Use #extend to access them at the class level: outside examples, as in "#before".)
  config.include( ControllerMacros, type: :controller )
  config.include( ControllerMacros, type: :features )

  config.extend( ControllerMacros, type: :controller )
  config.extend( CustomMatchers::Routing, type: :controller )

  # [Steve, 20140226] Configure FactoryBot to work with RSpec
  config.include( FactoryBot::Syntax::Methods )

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"


  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")


  # ============================================================================
  # Bullet gem global toggle:
  # ============================================================================
  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end
    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end


  # DatabaseCleaner standard setup:
  # config.before(:suite) do
    # if config.use_transactional_fixtures?
      # raise(<<-MSG)
        # Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        # (or set it to false) to prevent uncommitted transactions being used in
        # JavaScript-dependent specs.
#
        # During testing, the app-under-test that the browser driver connects to
        # uses a different database connection to the database connection used by
        # the spec. The app's database connection would not be able to access
        # uncommitted transaction data setup over the spec's database connection.
      # MSG
    # end
    # # Force the ORM to use truncation, since full blown transactions are not supported:
    # DatabaseCleaner[:mongoid].strategy = :truncation
    # DatabaseCleaner.clean_with(:truncation)
  # end

  # DatabaseCleaner w/ Capybara features setup:
  # config.before(:each, type: :feature) do
    # # :rack_test driver's Rack app under test shares database connection
    # # with the specs, so continue to use transaction strategy for speed.
    # driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
#
    # if !driver_shares_db_connection_with_specs
      # # Driver is probably for an external browser with an app
      # # under test that does *not* share a database connection with the
      # # specs, so use truncation strategy.
      # DatabaseCleaner.strategy = :truncation
    # end
  # end
#
  # config.before(:each) do
    # DatabaseCleaner.start
  # end
#
  # config.append_after(:each) do
    # DatabaseCleaner.clean
  # end
end
