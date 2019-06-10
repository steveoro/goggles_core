# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'
require 'sql_converter'

class DummySqlConverterIncludee

  include SqlConverter

end

describe SqlConverter, type: :strategy do
  subject do
    DummySqlConverterIncludee.new
  end

  let(:record)   { create(:training) }

  context 'as an included module,' do
    it_behaves_like('SqlConverter [param: let(:record)]')
  end
  #-- -------------------------------------------------------------------------
  #++

  # This test is here (instead of being inside the shared examples file) since
  # it refers to a specific use case for a record entity with some secondary
  # entities attached by a _"dependent: :delete"_ definition inside the source Model.
  #
  describe '#destroy_with_sql_capture' do
    # Create a deletable fixture, with some children rows:
    let(:meeting) { FactoryBot.create(:meeting_with_sessions) }

    it 'returns nil for an invalid parameter' do
      expect(subject.destroy_with_sql_capture(nil)).to be nil
    end

    it 'returns nil in case of deletion error' do
      unsaved_meeting = FactoryBot.build(:meeting)
      expect(subject.destroy_with_sql_capture(unsaved_meeting)).to be nil
    end

    it 'destroys the record (for a valid parameter)' do
      subject.destroy_with_sql_capture(meeting)
      expect(meeting.destroyed?).to be true
    end

    it 'returns the text log of the captured SQL DELETE statements issued (for a valid parameter)' do
      result_log = subject.destroy_with_sql_capture(meeting)
      expect(result_log).to be_a(String)
      # Test the log:
      expect(result_log).to include('DELETE')
      expect(result_log).to include(Meeting.table_name)
      expect(result_log).to include(meeting.id.to_s)
      expect(result_log).to include(MeetingSession.table_name)
      expect(result_log).to include(MeetingTeamScore.table_name)
      expect(result_log).to include(MeetingReservation.table_name)
      expect(result_log).to include(MeetingEventReservation.table_name)
      # DEBUG
      #      puts "\r\n---- CAPTURED SQL ----"
      #      puts result_log
      #      puts "----------------------"
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Style/FrozenStringLiteralComment
