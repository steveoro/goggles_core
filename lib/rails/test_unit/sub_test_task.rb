# [Steve, 20160915]
# Monkey-patch to make Draper happy with Rails 5 inside an Engine:
class Rails::SubTestTask < Rake::TestTask
end