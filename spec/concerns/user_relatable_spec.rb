require 'spec_helper'

require 'season'


# Dummy class holder for the fields used by the module
class DummyUserRelatableIncludee < Season
  include UserRelatable
end
# -----------------------------------------------------------------------------


describe DummyUserRelatableIncludee do
  it_behaves_like "UserRelatable"
end
