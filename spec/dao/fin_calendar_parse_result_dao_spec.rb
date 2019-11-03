# frozen_string_literal: true

require 'rails_helper'
require 'ffaker'

describe FinCalendarParseResultDAO, type: :model do
  context 'as a valid instance,' do
    let(:token_1)    { FFaker::Lorem.word }
    let(:token_2)    { FFaker::Lorem.word }
    let(:token_3)    { FFaker::Lorem.word }
    let(:token_src)  { FFaker::Lorem.paragraph }

    subject { FinCalendarParseResultDAO.new( token_1, token_2, 1, token_src ) }

    it_behaves_like( '(the existance of a method)', [
                      :date_day_token, :date_month_token, :start_time_token, :warmup_time_token,
                      :date_day_token=, :date_month_token=, :start_time_token=, :warmup_time_token=,
                      :header_date_iso_format, :start_time_iso_format, :warmup_time_iso_format, :day_part_type_id,
                      :header_date_iso_format=, :start_time_iso_format=, :warmup_time_iso_format=, :day_part_type_id=,
                      :organization_notes, :reference_name,
                      :organization_notes=, :reference_name=,

                      :meeting_place, :meeting_place=,
                      :pool_override_text, :pool_override_text=,

                      :pool_builder, :session_builder,
                      :pool_builder=, :session_builder=,

                      :event_tokens, :meeting_events, :session_order, :source_text_line,
                      :add_event_token, :add_meeting_event, :is_a_warmup?, :to_s
                    ] )

    describe '#add_event_token' do
      it 'increases the list of event tokens' do
        expect do
          subject.add_event_token( token_3 )
        end.to change { subject.event_tokens.count }.by( 1 )
      end
      it 'adds the token to the internal list of event tokens' do
        subject.add_event_token( token_3 )
        expect( subject.event_tokens ).to include( token_3 )
      end
    end

    describe '#add_meeting_event' do
      it 'increases the list of meeting events' do
        # (We actually don't care what is being added to the list.)
        expect  do
          subject.add_meeting_event( token_3 )
        end.to change { subject.meeting_events.count }.by( 1 )
      end
      it 'adds the item to the internal list of meeting events' do
        # (We actually don't care what is being added to the list.)
        subject.add_meeting_event( token_3 )
        expect( subject.meeting_events ).to include( token_3 )
      end
    end

    describe '#is_a_warmup?' do
      it 'returns true if the DAO contains just a warm-up token' do
        dao = FinCalendarParseResultDAO.new( token_1, token_2, 1, token_src )
        expect( dao.is_a_warmup? ).to be false
        dao.add_event_token( 'Riscaldamento' )
        expect( dao.is_a_warmup? ).to be true
      end
      it 'returns false if the DAO does not contain a warm-up token' do
        expect( subject.is_a_warmup? ).to be false
      end
    end

    describe '#to_s' do
      it 'is a string' do
        expect( subject.to_s ).to be_a(String)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++

describe FinCalendarParseResultDAO::EventTypeDAO, type: :model do
  context 'as a valid instance,' do
    let(:stroke_type)       { StrokeType.all.sample }
    let(:is_a_relay)        { [true, false].sample }
    let(:is_mixed_gender)   { [true, false].sample }
    let(:relay_phases)      { [4, 8].sample }
    let(:length_in_meters)  { [50, 100, 200, 400, 800].sample }

    subject { FinCalendarParseResultDAO::EventTypeDAO.new( stroke_type, is_a_relay, is_mixed_gender, relay_phases, length_in_meters ) }

    it_behaves_like( '(the existance of a method)', [
                      :stroke_type, :is_a_relay, :is_mixed_gender, :relay_phases, :length_in_meters,
                      :get_suggested_instance, :to_s, :get_full_name
                    ] )

    describe '#to_s' do
      it 'is a string' do
        expect( subject.to_s ).to be_a(String)
      end
    end

    describe '#get_full_name' do
      it 'is a string' do
        expect( subject.get_full_name ).to be_a(String)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
