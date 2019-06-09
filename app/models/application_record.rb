# frozen_string_literal: true

#
# = ApplicationRecord
#
#  Common abstract ancestor for all ActiveRecord models
#
#   - version:  6.00
#   - author:   Steve A.
#
class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

end
