require 'rails_helper'
require 'date'


describe MeetingSession, :type => :model do

  context "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [
      :description,
      :session_order,
      :scheduled_date
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  shared_examples_for( "date/time formatter method" ) do |method_name, member_name_sym, format_reg_expr, text_msg_for_not_available|
    describe "##{method_name}" do
      it "returns a String instance for a valid #{member_name_sym} value" do
        expect( subject.send(method_name) ).to be_an_instance_of( String )
      end
      it "returns a text formatted time for a valid #{member_name_sym} value" do
        expect( subject.send(method_name) ).to match( format_reg_expr )
      end
      it "returns '#{text_msg_for_not_available}' for a missing #{member_name_sym} value" do
        expect( create( :meeting_session, member_name_sym => nil ).send(method_name) ).to eq(text_msg_for_not_available)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # This section is separated from the context below because really it's
  # more of a functional test instead of normal unit test.
  context "[a valid, pre-existing seeded domain]" do
    # TODO It uses a just a single predetermined seed to verify the values => Use a factory, forcing how many detail rows will be created instead, and move to the section below.
    subject { Meeting.find_by_id(13105).meeting_sessions.last }

    it_behaves_like( "MeetingAccountable",
      # These values were hand-verified for Meeting #13105, sess. #314: (single-session meeting)
      1,    # team_id
      299,  # tot_male_results
      172,  # tot_female_results
      92,   # tot_team_results
      64,   # tot_male_entries
      34,   # tot_female_entries
      98    # tot_team_entries
    )
  end
  #-- -------------------------------------------------------------------------
  #++
  let(:meeting_session) { create( :meeting_session ) }


  context "[a well formed instance]" do
    before(:each) do
      create_list( :meeting_event, 5, meeting_session: meeting_session )
    end

    subject { meeting_session }


    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting
    ])

    describe "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_short_name,
        :get_full_name,
        :get_verbose_name,
        :get_short_events,
        :get_scheduled_date,
        :get_warm_up_time,
        :get_begin_time,

# FIXME helper methods moved away from MeetingSession. Use meeting_session.swimming_pool
#        :get_pool_attributes,
#        :get_pool_full_description,

        :get_order_with_date,
        :get_meeting_name,
        :get_meeting_verbose_name,
        :get_short_events
      ])

# FIXME helper methods moved away from MeetingSession. Use meeting_session.swimming_pool
# to get to these two:
#      it_behaves_like( "(the existance of a method returning numeric values)", [
#        :get_pool_length_in_meters,
#        :get_pool_lanes_number
#      ])


      it_behaves_like( "date/time formatter method", :get_warm_up_time, :warm_up_time, /\d{1,2}\:\d{1,2}/, '' )
      it_behaves_like( "date/time formatter method", :get_begin_time, :begin_time, /\d{1,2}\:\d{1,2}/, '' )

      describe "#get_scheduled_date" do
        it "returns a String instance" do
          expect( subject.get_scheduled_date ).to be_an_instance_of( String )
        end
        it "returns a text formatted time for a valid scheduled_date value" do
          expect( subject.get_scheduled_date ).to match( /\d{1,2}\-\d{1,2}\-\d{2,4}/ )
        end
      end


      describe "#get_short_name" do
        it "returns a String instance" do
          expect( subject.get_short_name ).to be_an_instance_of( String )
        end
        it "returns both day part type and event list in short format" do
          expect( subject.get_short_name ).to include( subject.get_day_part_type(:i18n_short) )
          expect( subject.get_short_name ).to include( subject.get_short_events )
        end
      end


      describe "#get_full_name" do
        it "returns a String instance" do
          expect( subject.get_full_name ).to be_an_instance_of( String )
        end
        it "returns at least the scheduled date, the day part type and the event list" do
          expect( subject.get_full_name ).to include( subject.get_scheduled_date )
          expect( subject.get_full_name ).to include( subject.get_day_part_type )
          expect( subject.get_full_name ).to include( subject.get_short_events )
        end
      end


      describe "#get_verbose_name" do
        it "returns a String instance" do
          expect( subject.get_verbose_name ).to be_an_instance_of( String )
        end
        it "returns at least the scheduled date, the day part type, the warm up time and the event list" do
          expect( subject.get_verbose_name ).to include( subject.get_scheduled_date )
          expect( subject.get_verbose_name ).to include( subject.get_day_part_type )
          expect( subject.get_verbose_name ).to include( subject.get_warm_up_time )
          expect( subject.get_verbose_name ).to include( subject.get_short_events )
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      describe "#get_event_types" do
        it "returns some kind of Enumerable" do
          expect( subject.get_event_types ).to be_a_kind_of( Enumerable )
        end
        it "returns a list of EventType" do
          subject.get_event_types.each do |event|
            expect( event ).to be_an_instance_of( EventType )
          end
        end
      end

      describe "#get_short_events" do
        it "returns a String instance" do
          expect( subject.get_short_events ).to be_an_instance_of( String )
        end
        it "returns a comma-separated list of event descriptions" do
          result = subject.get_short_events.split(',')
          expect( result ).to be_an_instance_of( Array )
          expect( result.size > 0 ).to be true
          result.each do |short_desc|
            expect( short_desc ).to be_an_instance_of( String )
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
