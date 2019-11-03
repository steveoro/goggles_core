# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme
# [Steve A., 20190609] WARNING: Spring on GogglesCore may yield a too big memory footprint,
# making its usage with Guard more or less impossible. Until further notice, stick with Zeus.

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

engine_name = 'goggles_core'

# Watch files that imply a bundle update:
guard :bundler do
  watch('Gemfile')
  watch("#{engine_name}.gemspec")
end

# With Spring:
# Start explicitly the Spring preloader & watch for files that may need Spring to refresh itself:
guard :spring, bundler: true do
  watch('Gemfile.lock')
  watch(%r{^config/})
  watch(%r{^spec/(support|factories)/})
  watch(%r{^spec/factory.rb})
end

rspec_options = {
  # With Zeus:
  # cmd: 'zeus test',
  # With Spring:
  cmd: 'spring rspec',
  # Exclude performance tests; to make it fail-fast, add option "--fail-fast":
  cmd_additional_args: ' --color --profile 10 -f progress --order rand -t ~type:performance',
  # (Zeus only) The following option must match the path in engine_plan.rb:
  results_file: File.join(Dir.pwd, 'tmp', 'guard_rspec_results.txt'),
  all_after_pass: false,
  failed_mode: :focus
}
# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

# Watch everything RSpec-related and run it:
guard :rspec, rspec_options do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files:
  rspec = dsl.rspec
  watch(rspec.spec_helper)  { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)
  # Ruby files:
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
  # Rails files:
  rails = dsl.rails(view_extensions: %w[erb haml slim])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) do |m|
    [
      rspec.spec.call("routing/#{m[1]}_routing"),
      rspec.spec.call("controllers/#{m[1]}_controller")
    ]
  end
  # Watch factories and launch the corresponding model specs:
  watch(%r{^spec/factories/(.+)\.rb$}) do |m|
    Dir[
      "spec/models/#{m[1]}*spec.rb"
    ]
  end
  # Rails config changes:
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }
  watch(rails.spec_helper)     { "#{rspec.spec_dir}/factories" }
  # [Steve A.] Commented-out so that we don't run feature specs inside RSpec:
  # Capybara features specs
  # watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
  # watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }
end

# OLD MATCHES VERSION:
#     # Watch support and config files:
#     watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
#     watch('spec/spec_helper.rb')                        { "spec" }
#     watch('spec/rails_helper.rb')                       { "spec" }
#     watch('config/routes.rb')                           { "spec/routing" }
#     watch(%r{^spec\/support\/(.+)\.rb$})                { "spec" }
#     watch('app/controllers/#{ engine_name }/application_controller.rb') { "spec/controllers" }
#
#     # Watch any spec files for changes:
#     watch( %r{^spec\/.+_spec\.rb$} )
#
#     # Watch factories and launch the specs for their corresponding model:
#     watch( %r{^spec\/factories\/(.+)\.rb$} ) do |m|
#       Dir[
#           "spec/models/#{ engine_name }/#{ m[1] }*spec.rb",
#           "spec/models/#{ engine_name }/#{ m[1].gsub( "#{engine_name}_", '' ) }*spec.rb"
#       ]
#     end
#
#     # Watch app sub-sub-dirs and spawn a corresponding spec re-check:
#     watch( %r{^app\/(.+)\/(.+)\.rb$} ) do |m|
#       Dir[ "spec/#{m[1]}/#{m[2]}*spec.rb" ]
#     end
#
#     # Watch dummy app files:
#     watch(%r{^spec/dummy/app\/(.+)\/(.+)\.rb$}) do |m|
# # DEBUG
# #      puts "Paths: '#{m.inspect}'"
# #      puts "spec/dummy/spec/#{m[1]}/#{m[2]}_spec.rb"
#       "spec/dummy/spec/#{m[1]}/#{m[2]}_spec.rb"
#     end
#   end
# end

rubocop_options = {
  # With Zeus:
  cmd: 'rubocop',
  # With Spring
  # cmd: 'spring rubocop',

  # With fuubar, offenses and warnings tot.:
  # cli: "-R -E -P -f fu -f o -f w"
  # [Steve, 20190609] (Do not turn on autocorrect when using Guard)
  # With rails cops enabled:
  cli: '-f fu -D --require rubocop-rails'
}

# Watch Ruby files for changes and run RuboCop:
# [See https://github.com/yujinakayama/guard-rubocop for all options]
guard :rubocop, rubocop_options do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
