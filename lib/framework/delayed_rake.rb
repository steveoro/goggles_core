# encoding: utf-8


=begin

= DelayedRake
  Rake caller class implementing +perform+ "interface" used by the delayed_job gem.

  Source example taken directly from delayed_job Wiki.

=== Sample usage:

  Delayed::Job.enqueue( DelayedRake.new("sql:exec") )

=end
class DelayedRake < Struct.new(:task, :options)

  # Executes the action using a delayed_job-compatible +perform+ method signature.
  #
  def perform
    env_options = ''
    options && options.stringify_keys!.each do |key, value|
      env_options << " #{key.upcase}=#{value}"
    end
    system( "cd #{Rails.root} && RAILS_ENV=#{Rails.env} bundle exec rake #{task} #{env_options} >> log/delayed_rake.log" )
  end
end
# -----------------------------------------------------------------------------