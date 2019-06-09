# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'

require 'goggle_cup'

# Dummy class holder for the fields used by the module
# Doesn't metter the model class used as base
class DummySqlConvertableIncludee < GoggleCup

  include SqlConvertable

end
# -----------------------------------------------------------------------------

describe DummySqlConvertableIncludee do
  subject = DummySqlConvertableIncludee.new

  it_behaves_like 'SqlConvertable [subject: includee]'
end
# rubocop:enable Style/FrozenStringLiteralComment
