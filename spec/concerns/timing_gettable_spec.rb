# frozen_string_literal: true

require 'rails_helper'

require 'user_result'

# Dummy class holder for the fields used by the module
class DummyTimingGettableIncludee < UserResult

  include TimingGettable

end
# -----------------------------------------------------------------------------

describe DummyTimingGettableIncludee do
  it_behaves_like 'TimingGettable'

  context '[general methods]' do
    it_behaves_like('(the existance of a method returning non-empty strings)', [:get_timing, :get_timing_flattened, :get_timing_custom])
  end
end
