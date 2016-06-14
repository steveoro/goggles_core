# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'


guard :shell do
  watch(/.*\.rb/) { |m| "#{m[0]} has changed." }

  # === Checking best-practices: ===
  # For a list of implemented best-practices, do checkout:
  # https://github.com/railsbp/rails_best_practices/wiki/How-to-write-your-own-check-list
  watch(/.*\.rb/) { |m| `bundle exec rails_best_practices #{m[0]}` }
end


Pry::Commands.block_command 'doc', "Use documentation formatter in rspec" do
  options = ::Guard.guards(:rspec).first.runner.options
  options[:cmd] = options[:cmd] =~ /\-f \w+/ ? options[:cmd].sub(/\-\-format \w+/, '--format documentation') : '--format documentation'
  output.puts "Using Documentation as RSpec formatter."
end

Pry::Commands.block_command 'prog', "Use progress formatter in rspec" do
  options = ::Guard.guards(:rspec).first.runner.options
  options[:cmd] = options[:cmd] =~ /\-f \w+/ ? options[:cmd].sub(/\-\-format \w+/, '--format progress') : '--format progress'
  output.puts "Using Progress as RSpec formatter."
end

Pry::Commands.block_command 't', "Touch files in specified path (usage: 't path_name_with_wildchars')" do |file_path|
  output.puts "Updating modification time for files under '#{file_path}'..."
  system( "touch -m #{file_path}" )
end

Pry::Commands.block_command 'integration-', "Excludes specs with tag type:integration" do
  options = ::Guard.guards(:rspec).first.runner.options
  options[:cmd] = options[:cmd] =~ /\-t \w+/ ? options[:cmd].sub(/\-\-tag \w+/, "--tag ~type:integration") : "#{options[:cmd]} --tag ~type:integration"
  output.puts "Ecluding tags with 'type:integration' (use 'reset' command to reverse this change)."
end

                                                    # === Specific Scopes: ===
group :model do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:model'
end
group :controller do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:controller'
end
group :strategy do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:strategy'
end
group :service do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:service'
end
group :request do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:request'
end
group :acceptance do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:acceptance'
end
group :mailer do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:mailer'
end
group :helper do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:helper'
end
group :feature do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:feature'
end

# Halt as soon as the first fail is found:
group :integration, halt_on_fail: true do
  guard :rspec, cmd: 'zeus rspec -f progress --tag type:integration'
end

                                                    # === Scope (GENERIC) Specs: ===
group :specs do
  guard :rspec, cmd: 'zeus rspec -f progress' do
    watch(%r{^spec\/.+_spec\.rb$})
    watch(%r{^lib\/(.+)\.rb$})                          { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')                        { "spec" }

    watch('spec/rails_helper.rb')                       { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }
    watch(%r{^spec\/support\/(.+)\.rb$})                { "spec" }

    # Watch any spec files for changes:
    watch(%r{^spec\/.+_spec\.rb$})

    # Watch factories and launch the specs for their corresponding model:
    watch(%r{^spec\/factories\/(.+)\.rb$}) do |m|
#      puts "m1: '#{m[1]}'"
      Dir[ "spec/models/#{m[1]}*spec.rb" ] +
      # Include also data_import models, if the change involves a primary entity:
      ( m[1] =~ /data_import/ ? [] : Dir[ "spec/models/data_import_#{m[1]}*spec.rb" ]  )
    end

    # Any App file with a matching spec:
    watch(%r{^app\/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app\/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }

    # Lib files with a nesting depth > 1:
    watch(%r{^lib\/(.+\/)(.+)\.rb$}) do |m|
#      puts "m1: '#{m[1]}', m2: '#{m[2]}'"
      [ "spec/lib/#{m[1]}#{m[2]}_spec.rb" ] +
      Dir[ "spec/integration/data_import/#{m[2]}*spec.rb" ]
    end

    # Data-Import files with a nesting depth > 1:
    watch(%r{data_import\/(.+\/)(.+)\.rb$}) do |m|
#      puts "m1: '#{m[1]}', m2: '#{m[2]}'"
      [ "spec/data_import/#{m[1]}#{m[2]}_spec.rb" ] +
      Dir[ "spec/integration/data_import/#{m[1]}#{m[2]}*spec.rb" ]
    end

    # Controller files:
    watch(%r{^app\/controllers\/(.+)_(controller)\.rb$}) do |m|
      [
        "spec/routing/#{m[1]}_routing_spec.rb",
    	"spec/acceptance/#{m[1]}_spec.rb"
      ] +
      # This will yield all filenames like "<plural_resource_name>_controller<anything>spec.rb":
      Dir[ 'spec/#{m[2]}s/#{m[1]}_#{m[2]}*spec.rb' ]
   	end

    # Capybara features specs:
    watch(%r{^app\/views\/(.+)/.*\.(erb|haml|slim)$})    { |m| "spec/features/#{m[1]}_spec.rb" }

    # Turnip features and steps:
    watch(%r{^spec\/acceptance\/(.+)\.feature$})
    watch(%r{^spec\/acceptance\/steps\/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
  end


#  guard :cucumber do
#    watch(%r{^features\/.+\.feature$})
#    watch(%r{^features\/support/.+$})                   { 'features' }
#    watch(%r{^features\/step_definitions\/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
#  end
end

