# frozen_string_literal: true

require 'rails_helper'

describe DataImportMeetingIndividualResult, type: :model do
  it_behaves_like 'TimingGettable'

  # TODO
  # describe "[a non-valid instance]" do
  # it_behaves_like( "(missing required values)", [ :number ])
  # end
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:data_import_meeting_individual_result) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end

    it 'refers to a valid meeting' do
      expect(subject.meeting).to be_valid
    end

    it 'refers to an individual result' do
      # Since the factory above assigns only data_import_meeting_program, we
      # don't have much to choose:
      expect(subject.data_import_meeting_program.event_type.is_a_relay).to be false
    end

    # TODO
    # Validated relations:
    # it_behaves_like( "(belongs_to required models)", [
    # :team,
    # :season,
    # :swimmer,
    # :category_type,
    # :entry_time_type
    # ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
