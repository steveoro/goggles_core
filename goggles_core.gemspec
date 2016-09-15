$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "goggles_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "goggles_core"
  s.version     = GogglesCore::VERSION
  s.authors     = ["Steve A."]
  s.email       = ["steve.alloro@gmail.com"]
  s.homepage    = "http://www.master-goggles.org"
  s.summary     = "Goggles Core engine"
  s.description = "contains Models, Strategies, Decorators, base DB structure and other tools for building the main front-end Goggles web app"

  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md"
  ]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5"
  s.add_dependency "jquery-rails"
  s.add_dependency "haml" #, '~> 4.0.5'

  s.add_dependency "mysql2" #, "~> 0.3.11"
  s.add_dependency "devise"
  s.add_dependency "devise-i18n"
  s.add_dependency "simple_token_authentication", '~> 1'

  s.add_dependency "execjs"
  s.add_dependency "therubyracer"

  s.add_dependency "acts_as_votable", "~> 0.10"
  s.add_dependency "acts-as-taggable-on", "~> 4"
  s.add_dependency "fuzzy-string-match_pure"        # [Steve, 20131106] Used for Team/Swimmer names comparison & existence checking

  s.add_dependency "draper" #, "~> 1.3"               # [Steve] For Decorator pattern support
# Draper usage: "rails generate decorator Article" for existing models,
# or "rails generate resource Article" to scaffold a new resource;
#   Single instance => Article.first.decorate
#   Indirect        => ArticleDecorator.decorate( OtherCompatibleModel.first )
#   Collection      => ArticleDecorator.decorate_collection( Article.all )

  # [Steve, 201600915] Used in new API/v3 namespace: (Requires Rails >= 4)
  s.add_dependency 'active_model_serializers', '~> 0.10.0'
  s.add_dependency 'active_hash_relation'
  s.add_dependency 'activemodel-serializers-xml' # Required by Draper

  s.add_development_dependency "test-unit", "~> 3.0"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-shell"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "ffaker"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency "better_errors", "~> 1.1.0"
end
