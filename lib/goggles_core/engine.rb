require 'devise'
require 'simple_token_authentication'
require 'draper'
require 'haml'
require 'acts-as-taggable-on'
require 'acts_as_votable'

require 'extensions/roman_numeral'


module GogglesCore
  class Engine < ::Rails::Engine
    # Add load paths for this specific Engine
    # [Steve A.] When in doubt, open the console and do a...
    #   $> puts ActiveSupport::Dependencies.autoload_paths
    # ...To check the actual resulting paths.
    config.autoload_paths << File.expand_path("../../framework", __FILE__)
    config.autoload_paths << File.expand_path("../../common", __FILE__)
    config.autoload_paths << File.expand_path("../../wrappers", __FILE__)
    config.autoload_paths << File.expand_path("../../extensions", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/dao", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/dao/enhance_individual_ranking_dao", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/strategies", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/concerns", __FILE__)

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.factory_girl dir: 'spec/factories'
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
