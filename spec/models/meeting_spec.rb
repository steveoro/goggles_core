# frozen_string_literal: true

require 'rails_helper'
require 'date'

describe Meeting, type: :model do
  context '[a non-valid instance]' do
    it_behaves_like('(missing required values)', [:description, :code])
  end
  #-- -------------------------------------------------------------------------
  #++

  # This section is separated from the context below because really it's
  # more of a functional test instead of normal unit test.
  context '[a valid, pre-existing seeded domain]' do
    # TODO: It uses a just a single predetermined seed to verify the values => Use a factory, forcing how many detail rows will be created instead, and move to the section below.
    subject { Meeting.find_by(id: 13_105) }

    it_behaves_like('MeetingAccountable',
                    # These values were hand-verified for Meeting #13105:
                    1,    # team_id
                    299,  # tot_male_results
                    172,  # tot_female_results
                    92,   # tot_team_results
                    64,   # tot_male_entries
                    34,   # tot_female_entries
                    98) # tot_team_entries
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:meeting) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:season, :edition_type, :timing_type])

    it_behaves_like('(the existance of a class method)', [
                      # Filtering scopes:
                      :has_only_invitation,
                      :has_only_start_list,
                      :has_results,
                      :has_not_results,
                      :is_not_closed,
                      :is_not_cancelled
                    ])
    #-- -----------------------------------------------------------------------
    #++

    context '[general methods]' do
      it_behaves_like('(the existance of a method)', [
                        # Fields:
                        :code, :header_date, :header_year, :edition, :description,
                        :entry_deadline,
                        :has_warm_up_pool, :is_under_25_admitted,
                        :reference_phone, :reference_e_mail, :reference_name, :notes,

                        :has_invitation, :invitation,
                        :has_start_list, :are_results_acquired,

                        :max_individual_events, :configuration_file,
                        :is_autofilled,
                        :max_individual_events_per_session, :is_out_of_season,
                        :is_confirmed,
                        :do_not_update
                      ])

      it_behaves_like('(the existance of a method returning non-empty and non-? strings)', [:get_short_name, :get_full_name, :get_verbose_name])

      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_short_events, :get_complete_events, :get_city])

      it_behaves_like('(the existance of a method)', [:get_edition, :get_scheduled_date, :get_meeting_date, :get_scheduled_date_with_verbose_name, :get_season_type, :get_short_dates, :get_session_dates, :get_session_warm_up_times, :get_session_begin_times, :get_swimming_pool, :get_pool_type, :get_events_by_pool_types, :meeting_date_to_iso, :get_data_import_file_name])
    end

    context '[meeting structure methods]' do
      it 'has a method to find out meeting pool type' do
        expect(subject).to respond_to(:get_pool_type)
      end
      it 'returns a valid pool type for 14105 meeting (Reggio Emilia CSI)' do
        fix_meeting = Meeting.find(14_105)
        expect(fix_meeting.get_pool_type).to be_an_instance_of(PoolType)
      end
      it 'returns 50 pool type for 14105 meeting (Reggio Emilia CSI)' do
        fix_meeting = Meeting.find(14_105)
        pool_type = fix_meeting.get_pool_type
        expect(pool_type.code).to eq('50')
      end
      it 'returns 25 pool type for 14101 meeting (Parma CSI)' do
        fix_meeting = Meeting.find(14_101)
        pool_type = fix_meeting.get_pool_type
        expect(pool_type.code).to eq('25')
      end

      it 'has a method to find out meeting events by pool type' do
        expect(subject).to respond_to(:get_events_by_pool_types)
      end
      it 'returns an array' do
        fix_meeting_50 = Meeting.find(14_105)
        fix_meeting_25 = Meeting.find(14_101)
        expect(subject.get_events_by_pool_types).to be_a_kind_of(Array)
        expect(fix_meeting_50.get_events_by_pool_types).to be_a_kind_of(Array)
        expect(fix_meeting_25.get_events_by_pool_types).to be_a_kind_of(Array)
      end
      it 'returns an array of events by pool types' do
        fix_meeting_50 = Meeting.find(14_105)
        event_by_pool_types = fix_meeting_50.get_events_by_pool_types
        expect(event_by_pool_types.count).to eq(5)
        event_by_pool_types.each do |event_by_pool_type|
          expect(event_by_pool_type).to be_an_instance_of(EventsByPoolType)
        end
        fix_meeting_25 = Meeting.find(14_101)
        event_by_pool_types = fix_meeting_25.get_events_by_pool_types
        expect(event_by_pool_types.count).to eq(5)
        event_by_pool_types.each do |event_by_pool_type|
          expect(event_by_pool_type).to be_an_instance_of(EventsByPoolType)
        end
      end

      describe '#get_meeting_date' do
        it 'has a method to find out meeting date' do
          expect(subject).to respond_to(:get_meeting_date)
        end
        it 'returns a string' do
          expect(subject.get_meeting_date).to be_an_instance_of(String)
        end
      end

      describe '#meeting_date_to_iso' do
        it 'has a method to find out meeting date in iso format' do
          expect(subject).to respond_to(:meeting_date_to_iso)
        end
        it 'returns a string' do
          expect(subject.meeting_date_to_iso).to be_an_instance_of(String)
        end
        it 'returns a string containing the meeting date' do
          str_date = subject.get_meeting_date
          expect(subject.meeting_date_to_iso).to eq(str_date.to_date.strftime('%Y%m%d'))
        end
      end

      describe '#get_data_import_file_name' do
        it 'has a method to find out meeting data import file name' do
          expect(subject).to respond_to(:get_data_import_file_name)
        end
        it 'returns a string' do
          expect(subject.get_data_import_file_name).to be_an_instance_of(String)
        end
        it 'returns a string containing the meeting date' do
          str_date = subject.get_meeting_date
          expect(subject.get_data_import_file_name).to include(str_date.to_date.strftime('%Y%m%d'))
        end
        it 'returns a string containing the meeting code' do
          expect(subject.get_data_import_file_name).to include(subject.code)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#organization_team=,' do
      subject { Meeting.all.sample }
      it 'allows a team_id to be set as the event organization' do
        # Test an assignment without saving, just to test validity:
        expect(subject).to be_valid
        subject.organization_team = Team.all.sample
        expect(subject.organization_team).to be_valid
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
