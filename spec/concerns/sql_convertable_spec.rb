# frozen_string_literal: true

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
