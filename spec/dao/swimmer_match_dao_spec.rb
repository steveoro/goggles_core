# frozen_string_literal: true

require 'rails_helper'

describe SwimmerMatchDAO, type: :model do
  context 'SwimmerMatchProgramDAO subclass,' do
    let(:description)        { "This is the match number #{(rand * 100).to_i}" }
    let(:fix_event)          { EventType.are_not_relays[(rand * (EventType.are_not_relays.count - 1)).to_i] }

    subject { SwimmerMatchDAO::SwimmerMatchProgramDAO.new }

    describe '[a well formed instance]' do
      it "hasn't description if not given" do
        expect(subject.description).to be nil
      end
      it 'description is the one used in costruction' do
        with_desc = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, nil, description)
        expect(with_desc.description).to eq(description)
      end
      it 'local_result is the one used in costruction' do
        mir = create(:meeting_individual_result)
        with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(mir, nil)
        expect(with_loc_res.local_result).to eq(mir)
        expect(with_loc_res.visitor_result).to be nil
      end
      it 'visitor_result is the one used in costruction' do
        mir = create(:meeting_individual_result)
        with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, mir)
        expect(with_loc_res.local_result).to be nil
        expect(with_loc_res.visitor_result).to eq(mir)
      end
      it 'stored values are the one used in costruction' do
        mir_loc = create(:meeting_individual_result)
        mir_vis = create(:meeting_individual_result)
        full = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(mir_loc, mir_vis, description)
        expect(full.local_result).to eq(mir_loc)
        expect(full.visitor_result).to eq(mir_vis)
        expect(full.description).to eq(description)
      end

      it 'responds to local_result' do
        expect(subject).to respond_to(:local_result)
      end

      it 'responds to visitor_result' do
        expect(subject).to respond_to(:visitor_result)
      end

      describe '#get_description' do
        it 'responds to #get_description' do
          expect(subject).to respond_to(:get_description)
        end
        it 'returns a string' do
          expect(subject.get_description).to be_an_instance_of(String)
        end
        it "returns a '?' if no data set" do
          no_desc = SwimmerMatchDAO::SwimmerMatchProgramDAO.new
          expect(no_desc.description).to be nil
          expect(no_desc.local_result).to be nil
          expect(no_desc.get_description).to eq('?')
        end
        it 'returns the description attribute if set' do
          with_desc = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, nil, description)
          expect(with_desc.description).not_to be nil
          expect(with_desc.get_description).to eq(with_desc.description)
        end
        it 'returns the locale result description if result present and no description attribute set' do
          mir = create(:meeting_individual_result)
          expect(subject.description).to be nil
          subject.local_result = mir
          expect(subject.get_description).to include(mir.get_full_name)
        end
      end

      describe '#get_meeting' do
        it 'responds to #get_meeting' do
          expect(subject).to respond_to(:get_meeting)
        end
        it 'returns the meeting used in costruction' do
          meeting = create(:meeting)
          with_meeting = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, nil, nil, meeting)
          expect(with_meeting.get_meeting).to eq(meeting)
        end
        it 'returns ? if not set' do
          expect(subject.get_meeting).to eq('?')
        end
        it 'returns teh locale result meeting if set' do
          mir = create(:meeting_individual_result)
          with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(mir)
          meeting = with_loc_res.get_meeting
          expect(meeting).to be_an_instance_of(Meeting)
          expect(meeting).to eq(mir.meeting)
        end
      end

      describe '#get_event_type' do
        it 'responds to #get_event_type' do
          expect(subject).to respond_to(:get_event_type)
        end
        it 'returns the event_type used in costruction' do
          with_event = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, nil, nil, nil, fix_event)
          expect(with_event.get_event_type).to eq(fix_event)
        end
        it 'returns ? if not set' do
          expect(subject.get_event_type).to eq('?')
        end
        it 'returns teh locale result event_type if set' do
          mir = create(:meeting_individual_result)
          with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(mir)
          event_type = with_loc_res.get_event_type
          expect(event_type).to be_an_instance_of(EventType)
          expect(event_type).to eq(mir.event_type)
        end
      end

      describe '#get_locale_timing' do
        it 'responds to #get_locale_timing' do
          expect(subject).to respond_to(:get_locale_timing)
        end
        it 'returns the locale result timing if set' do
          mir = create(:meeting_individual_result)
          with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(mir)
          timing = with_loc_res.get_locale_timing
          expect(timing).to be_a_kind_of(String)
          expect(timing).to eq(mir.get_timing)
          expect(with_loc_res.get_visitor_timing).to be nil
        end
        it 'returns nil if locale result not set' do
          expect(subject.get_locale_timing).to be nil
        end
      end

      describe '#get_visitor_timing' do
        it 'responds to #get_visitor_timing' do
          expect(subject).to respond_to(:get_visitor_timing)
        end
        it 'returns the visitor result timing if set' do
          mir = create(:meeting_individual_result)
          with_loc_res = SwimmerMatchDAO::SwimmerMatchProgramDAO.new(nil, mir)
          timing = with_loc_res.get_visitor_timing
          expect(timing).to be_a_kind_of(String)
          expect(timing).to eq(mir.get_timing)
          expect(with_loc_res.get_locale_timing).to be nil
        end
        it 'returns nil if locale result not set' do
          expect(subject.get_visitor_timing).to be nil
        end
      end
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'SwimmerMatchEventSumDAO subclass,' do
    let(:fix_event)          { EventType.are_not_relays[(rand * EventType.are_not_relays.count).to_i] }
    let(:fix_value)          { (rand * 15).to_i + 1 }

    subject { SwimmerMatchDAO::SwimmerMatchEventSumDAO.new(fix_event) }

    describe '[a well formed instance]' do
      it 'responds to event_type' do
        expect(subject).to respond_to(:event_type)
      end
      it 'responds to wons_count' do
        expect(subject).to respond_to(:wons_count)
      end
      it 'responds to losses_count' do
        expect(subject).to respond_to(:losses_count)
      end
      it 'responds to neutrals_count' do
        expect(subject).to respond_to(:neutrals_count)
      end

      it 'event_type is the one used in costruction' do
        expect(subject.event_type).to eq(fix_event)
      end
      it 'summary data are 0 if not given in costruction' do
        expect(subject.wons_count).to eq(0)
        expect(subject.losses_count).to eq(0)
        expect(subject.neutrals_count).to eq(0)
      end
      it 'wons_count is the one used in costruction' do
        expect(SwimmerMatchDAO::SwimmerMatchEventSumDAO.new(fix_event, fix_value).wons_count).to eq(fix_value)
        expect(subject.losses_count).to eq(0)
        expect(subject.neutrals_count).to eq(0)
      end
      it 'losses_count is the one used in costruction' do
        expect(SwimmerMatchDAO::SwimmerMatchEventSumDAO.new(fix_event, 0, fix_value).losses_count).to eq(fix_value)
        expect(subject.wons_count).to eq(0)
        expect(subject.neutrals_count).to eq(0)
      end
      it 'neutrals_count is the one used in costruction' do
        expect(SwimmerMatchDAO::SwimmerMatchEventSumDAO.new(fix_event, 0, 0, fix_value).neutrals_count).to eq(fix_value)
        expect(subject.wons_count).to eq(0)
        expect(subject.losses_count).to eq(0)
      end

      describe '#increment' do
        it 'responds to #increment' do
          expect(subject).to respond_to(:increment)
        end
        it 'increments the wons summary voice' do
          now = subject.wons_count
          subject.increment(:wons)
          expect(subject.wons_count).to be > now
        end
        it 'increments the losses summary voice' do
          now = subject.losses_count
          subject.increment(:losses)
          expect(subject.losses_count).to be > now
        end
        it 'increments the neutrals summary voice' do
          now = subject.neutrals_count
          subject.increment(:neutrals)
          expect(subject.neutrals_count).to be > now
        end
      end
      #-- -------------------------------------------------------------------------
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  subject { SwimmerMatchDAO.new }

  describe '[a well formed instance]' do
    let(:valid_swimmer)  { create(:swimmer) }
    let(:valid_mir)      { create(:meeting_individual_result, swimmer: valid_swimmer, minutes: 1) }
    let(:worst_mir)      { create(:meeting_individual_result, swimmer: valid_swimmer, minutes: 2) }
    let(:best_mir)       { create(:meeting_individual_result, swimmer: valid_swimmer, minutes: 0) }

    it 'responds to get_locale' do
      expect(subject).to respond_to(:get_locale)
    end

    it 'responds to get_visitor' do
      expect(subject).to respond_to(:get_visitor)
    end

    it_behaves_like('(existance of a member array)', [:wons, :losses, :neutrals, :events_summary])

    it_behaves_like('(the existance of a method returning numeric values)', [:get_wons_count, :get_losses_count, :get_neutrals_count, :get_matches_count])

    it 'responds to first_meeting' do
      expect(subject).to respond_to(:first_meeting)
      expect(subject.first_meeting).to be nil
    end
    it 'responds to first_meeting' do
      expect(subject).to respond_to(:last_meeting)
      expect(subject.last_meeting).to be nil
    end

    describe '#set_locale' do
      it 'responds to #set_locale' do
        expect(subject).to respond_to(:set_locale)
      end
      it 'sets the locale swimmer if a valid swimmer given' do
        expect(subject.get_locale).to be nil
        subject.set_locale(valid_swimmer)
        expect(subject.get_locale).to eq(valid_swimmer)
      end
      it "doesn't set locale swimmer if wrong swimmer parameter" do
        expect(subject.get_locale).to be nil
        subject.set_locale('wrong_parameter')
        expect(subject.get_locale).to be nil
      end
    end
    #-- -------------------------------------------------------------------------

    describe '#set_visitor' do
      it 'responds to #set_visitor' do
        expect(subject).to respond_to(:set_visitor)
      end
      it 'sets the visitor swimmer if a valid swimmer given' do
        expect(subject.get_visitor).to be nil
        subject.set_visitor(valid_swimmer)
        expect(subject.get_visitor).to eq(valid_swimmer)
      end
      it "doesn't set visitor swimmer if wrong swimmer parameter" do
        expect(subject.get_visitor).to be nil
        subject.set_visitor('wrong_parameter')
        expect(subject.get_visitor).to be nil
      end
    end
    #-- -------------------------------------------------------------------------

    describe '#add_match' do
      it 'responds to #add_match' do
        expect(subject).to respond_to(:add_match)
      end
      it 'returns -1 if wrong parameters' do
        expect(subject.add_match(valid_mir, 'wrong_parameter')).to eq(-1)
        expect(subject.add_match(valid_mir, valid_mir)).to eq(-1)
      end
      it 'returns a number >= 0 if correct parameters' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.add_match(valid_mir, valid_mir)).to be >= 0
      end
      it 'adds a match to the neutrals collection if same timing' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.get_neutrals_count).to eq(0)
        expect(subject.add_match(valid_mir, valid_mir)).to be >= 0
        expect(subject.get_neutrals_count).to eq(1)
      end
      it 'adds a match to the wons collection if better timing' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.get_wons_count).to eq(0)
        expect(subject.add_match(valid_mir, worst_mir)).to be >= 0
        expect(subject.get_wons_count).to eq(1)
      end
      it 'adds a match to the losses collection if worst timing' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.get_losses_count).to eq(0)
        expect(subject.add_match(worst_mir, valid_mir)).to be >= 0
        expect(subject.get_losses_count).to eq(1)
      end
      it "doesn't add twice the same match" do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        matches = subject.add_match(valid_mir, valid_mir)
        expect(subject.add_match(valid_mir, valid_mir)).to eq(0)
        expect(subject.get_matches_count).to eq(matches)
        matches = subject.add_match(valid_mir, worst_mir)
        expect(subject.add_match(valid_mir, worst_mir)).to eq(0)
        expect(subject.get_matches_count).to eq(matches)
        matches = subject.add_match(worst_mir, valid_mir)
        expect(subject.add_match(worst_mir, valid_mir)).to eq(0)
        expect(subject.get_matches_count).to eq(matches)
      end
      it 'creates event summary element' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.events_summary.count).to eq(0)
        matches = subject.add_match(valid_mir, valid_mir)
        expect(subject.events_summary.count).to eq(1)
      end
      it 'populates matches with SwimmerMatchProgramDAO elements' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        subject.add_match(valid_mir, worst_mir)
        subject.add_match(worst_mir, valid_mir)
        subject.add_match(worst_mir, worst_mir)
        subject.add_match(valid_mir, best_mir)
        subject.add_match(best_mir, valid_mir)
        subject.add_match(best_mir, worst_mir)
        subject.add_match(worst_mir, best_mir)
        expect(subject.wons).to all(be_an_instance_of(SwimmerMatchDAO::SwimmerMatchProgramDAO))
        expect(subject.losses).to all(be_an_instance_of(SwimmerMatchDAO::SwimmerMatchProgramDAO))
        expect(subject.neutrals).to all(be_an_instance_of(SwimmerMatchDAO::SwimmerMatchProgramDAO))
      end
      it 'populates event summary with SwimmerMatchEventSumDAO elements' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        subject.add_match(valid_mir, worst_mir)
        subject.add_match(worst_mir, valid_mir)
        subject.add_match(worst_mir, worst_mir)
        subject.add_match(best_mir, valid_mir)
        subject.add_match(best_mir, worst_mir)
        expect(subject.events_summary).to all(be_an_instance_of(SwimmerMatchDAO::SwimmerMatchEventSumDAO))
      end
      it 'populates event summary with the local result event type' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        subject.add_match(valid_mir, worst_mir)
        subject.add_match(valid_mir, best_mir)
        expect(subject.events_summary.count).to eq(1)
        expect(subject.events_summary[0].event_type.code).to eq(valid_mir.event_type.code)
      end
      it 'populates event summary with all matches result types' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        subject.add_match(valid_mir, worst_mir)
        subject.add_match(valid_mir, best_mir)
        expect(subject.events_summary.count).to eq(1)
        expect(subject.events_summary[0].wons_count).to eq(1)
        expect(subject.events_summary[0].losses_count).to eq(1)
        expect(subject.events_summary[0].neutrals_count).to eq(1)
      end
      it 'populates event summary with all locale result event types' do
        random_mirs = create_list(:meeting_individual_result, (rand * 20).to_i + 5, swimmer: valid_swimmer)
        expect(random_mirs.map(&:event_type).uniq.count).to be > 1
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        random_mirs.each do |mir|
          subject.add_match(mir, valid_mir)
        end
        expect(subject.events_summary.count).to be >= 0
        expect(subject.events_summary.count).to eq(random_mirs.map(&:event_type).uniq.count)
        random_mirs.map(&:event_type).uniq.each do |event_type|
          expect(subject.events_summary.rindex { |e| e.event_type == event_type }).not_to be nil
        end
      end
      it 'populates data for matches and summaries' do
        random_mirs = create_list(:meeting_individual_result, (rand * 20).to_i + 5, swimmer: valid_swimmer)
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        random_mirs.each do |mir|
          subject.add_match(mir, valid_mir)
        end
        event_summary_total = 0
        subject.events_summary.each do |event_summary|
          event_summary_total += event_summary.wons_count
          event_summary_total += event_summary.losses_count
          event_summary_total += event_summary.neutrals_count
        end
        expect(subject.get_matches_count).to eq(event_summary_total)
      end
      it 'populates first_meeting' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        expect(subject.first_meeting).not_to be nil
        expect(subject.first_meeting).to be_an_instance_of(Meeting)
        expect(subject.first_meeting).to be valid_mir.meeting
      end
      it 'populates last_meeting' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        subject.add_match(valid_mir, valid_mir)
        expect(subject.last_meeting).not_to be nil
        expect(subject.last_meeting).to be_an_instance_of(Meeting)
        expect(subject.last_meeting).to be valid_mir.meeting
      end
      it 'populates first_meeting with the oldest of the matches' do
        random_mirs = create_list(:meeting_individual_result, (rand * 20).to_i + 5, swimmer: valid_swimmer)
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        random_mirs.each do |mir|
          subject.add_match(mir, valid_mir)
        end
        expect(subject.first_meeting).not_to be nil
        random_mirs.each do |mir|
          expect(subject.first_meeting.get_meeting_date.to_date).to be <= mir.meeting.get_meeting_date.to_date
        end
      end
      it 'populates last_meeting with the newest of the matches' do
        random_mirs = create_list(:meeting_individual_result, (rand * 20).to_i + 5, swimmer: valid_swimmer)
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        random_mirs.each do |mir|
          subject.add_match(mir, valid_mir)
        end
        expect(subject.last_meeting).not_to be nil
        random_mirs.each do |mir|
          expect(subject.last_meeting.get_meeting_date.to_date).to be >= mir.meeting.get_meeting_date.to_date
        end
      end
    end
    #-- -------------------------------------------------------------------------

    describe '#get_matches_count' do
      it 'returns 0 far a new instance' do
        expect(subject.get_matches_count).to eq(0)
      end
      it 'returns a number > 0 far a populated instance' do
        subject.set_locale(valid_swimmer)
        subject.set_visitor(valid_swimmer)
        expect(subject.add_match(valid_mir, valid_mir)).to be >= 0
        expect(subject.get_matches_count).to be > 0
      end
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
end
