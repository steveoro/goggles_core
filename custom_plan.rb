require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

end

ENV["RAILS_ENV"] = 'test'
Zeus.plan = CustomPlan.new
