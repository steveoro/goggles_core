source "https://rubygems.org"

# Declare your gem's dependencies in goggles_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

gem "amistad", git: "https://github.com/fasar-sw/amistad.git", branch: 'rails5'  # [Steve] Customized version. For Facebook-like friendship management

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

group :test do
  gem "zeus", require: false
end
