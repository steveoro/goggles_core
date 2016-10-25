require 'devise'
require 'simple_token_authentication'
require 'draper'
require 'haml'
require 'acts-as-taggable-on'
require 'acts_as_votable'

require 'extensions/roman_numeral'


module GogglesCore
  class Engine < ::Rails::Engine
    # Add a load path for this specific Engine
    config.autoload_paths << File.expand_path("../lib/framework", __FILE__)
    config.autoload_paths << File.expand_path("../lib/common", __FILE__)
    config.autoload_paths << File.expand_path("../lib/wrappers", __FILE__)
    config.autoload_paths << File.expand_path("../lib/extensions", __FILE__)
    config.autoload_paths << File.expand_path("../app/dao", __FILE__)
    config.autoload_paths << File.expand_path("../app/dao/enhance_individual_ranking_dao", __FILE__)
    config.autoload_paths << File.expand_path("../app/strategies", __FILE__)
    config.autoload_paths << File.expand_path("../app/concerns", __FILE__)

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.factory_girl dir: 'spec/factories'
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
