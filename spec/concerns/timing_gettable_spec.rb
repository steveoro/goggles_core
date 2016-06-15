require 'spec_helper'


# Dummy class holder for the fields used by the module
class DummyTimingGettableIncludee < UserResult
  include TimingGettable
end
# -----------------------------------------------------------------------------


describe DummyTimingGettableIncludee do
  it_behaves_like "TimingGettable"
end
