# frozen_string_literal: true

require 'rails_helper'

describe MeetingDateChanger, type: :strategy do
  let(:meeting)         { create(:meeting_with_sessions) }
  let(:days_to_move_on) { ((rand * 5) * 7).to_i }
  let(:confirm)         { (rand >= 0.5) }

  context 'with requested parameters' do
    subject { MeetingDateChanger.new(meeting, days_to_move_on, confirm) }

    it_behaves_like('(the existance of a method)', [:meeting, :days_to_move_on, :confirm, :sql_diff_text_log, :move_meeting_date!])

    let(:record) { meeting }
    it_behaves_like('SqlConverter [param: let(:record)]')
    it_behaves_like('SqlConvertable [subject: includee]')

    describe '#parameters,' do
      it 'are the given parameters' do
        expect(subject.meeting).to eq(meeting)
        expect(subject.days_to_move_on).to eq(days_to_move_on)
        expect(subject.confirm).to eq(confirm)
      end
      it 'sets default parameters' do
        not_confirming_mdc = MeetingDateChanger.new(meeting, days_to_move_on)
        expect(not_confirming_mdc.confirm).to be false
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#move_meeting_date!,' do
      it 'returns a valid date' do
        expect(subject.move_meeting_date!).to be_a_kind_of(Date)
      end
      it 'returns the expected date' do
        previous_date = subject.meeting.header_date
        expect(subject.move_meeting_date!).to eq(previous_date + days_to_move_on)
      end
      it 'changes meeting header date' do
        new_date = subject.move_meeting_date!
        expect(subject.meeting.header_date).to eq(new_date)
      end
      it 'persists changes' do
        new_date = subject.move_meeting_date!
        expect(Meeting.find(subject.meeting.id).header_date).to eq(new_date)
      end
      it 'confirms meeting if requested' do
        subject.confirm = true
        subject.meeting.is_confirmed = false
        subject.move_meeting_date!
        expect(subject.meeting.is_confirmed).to be true
      end
      it "doesn't confirm meeting if not requested" do
        subject.confirm = false
        subject.meeting.is_confirmed = false
        subject.move_meeting_date!
        expect(subject.meeting.is_confirmed).to be false
      end
    end

    describe '#move_meeting_session_date!,' do
      it 'returns a valid date' do
        subject.meeting.meeting_sessions.each do |meeting_session|
          expect(subject.move_meeting_session_date!(meeting_session)).to be_a_kind_of(Date)
        end
      end
      it 'returns the expected date' do
        subject.meeting.meeting_sessions.each do |meeting_session|
          previous_date = meeting_session.scheduled_date
          expect(subject.move_meeting_session_date!(meeting_session)).to eq(previous_date + days_to_move_on)
        end
      end
      it 'changes meeting session scheduled dates' do
        subject.meeting.meeting_sessions.each do |meeting_session|
          previous_date = meeting_session.scheduled_date
          expect(subject.move_meeting_session_date!(meeting_session)).to eq(previous_date + days_to_move_on)
        end
      end
      it 'persists changes' do
        subject.meeting.meeting_sessions.each do |meeting_session|
          new_date = subject.move_meeting_session_date!(meeting_session)
          expect(MeetingSession.find(meeting_session.id).scheduled_date).to eq(new_date)
        end
      end
    end

    describe '#change_dates!,' do
      it 'creates diff sql script' do
        expect(subject.sql_diff_text_log.size).to eq(0)
        subject.change_dates!
        expect(subject.sql_diff_text_log.size).to be > 0
      end
      it 'changes meeting dates' do
        previous_date = subject.meeting.header_date
        subject.change_dates!
        expect(Meeting.find(subject.meeting.id).header_date).to eq(previous_date + days_to_move_on)
      end
      it 'changes meeting sessions dates' do
        subject.meeting.meeting_sessions.each do |meeting_session|
          previous_date = meeting_session.scheduled_date
          subject.change_dates!
          expect(MeetingSession.find(meeting_session.id).scheduled_date).to eq(previous_date + days_to_move_on)
        end
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'without requested parameters' do
    it 'raises an exception for wrong parameters' do
      expect { MeetingDateChanger.new }.to raise_error(ArgumentError)
      expect { MeetingDateChanger.new(7) }.to raise_error(ArgumentError)
      expect { MeetingDateChanger.new(meeting) }.to raise_error(ArgumentError)
      meeting.header_date = nil
      expect { MeetingDateChanger.new(meeting, 7) }.to raise_error(ArgumentError)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
