# frozen_string_literal: true

require 'rails_helper'

require 'meeting_entry'

# Dummy class holder for the fields used by the module
class DummySwimmerRelatableIncludee < MeetingEntry

  include SwimmerRelatable

end
# -----------------------------------------------------------------------------

describe DummySwimmerRelatableIncludee do
  it_behaves_like 'SwimmerRelatable'
end
