require 'devise'
require 'simple_token_authentication'
require 'draper'
require 'haml'
require 'acts-as-taggable-on'
require 'acts_as_votable'

require 'extensions/roman_numeral'
require 'framework/application_constants'


module GogglesCore
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.factory_girl dir: 'spec/factories'
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
