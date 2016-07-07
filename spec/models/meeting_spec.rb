require 'rails_helper'
require 'date'

describe Meeting, :type => :model do

  context "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ 
      :description,
      :code
    ])    
  end
  #-- -------------------------------------------------------------------------
  #++

  # This section is separated from the context below because really it's
  # more of a functional test instead of normal unit test.
  context "[a valid, pre-existing seeded domain]" do
    # TODO It uses a just a single predetermined seed to verify the values => Use a factory, forcing how many detail rows will be created instead, and move to the section below.
    subject { Meeting.find_by_id(13105) }

    it_behaves_like( "MeetingAccountable",
      # These values were hand-verified for Meeting #13105:
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

  context "[a well formed instance]" do
    subject { create( :meeting ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [ 
      :season,
      :edition_type,
      :timing_type
    ])    

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty and non-? strings)", [ 
        :get_short_name,
        :get_full_name,
        :get_verbose_name
      ])
      it_behaves_like( "(the existance of a method returning non-empty strings)", [ 
        :get_short_events,
        :get_complete_events,
        :get_city
      ])
    end

    context "[meeting structure methods]" do
      it "has a method to find out meeting pool type" do
        expect( subject ).to respond_to( :get_pool_type )
      end
      it "returns a valid pool type for 14105 meeting (Reggio Emilia CSI)" do
        fix_meeting = Meeting.find( 14105 )
        expect( fix_meeting.get_pool_type ).to be_an_instance_of( PoolType )
      end
      it "returns 50 pool type for 14105 meeting (Reggio Emilia CSI)" do
        fix_meeting = Meeting.find( 14105 )
        pool_type = fix_meeting.get_pool_type
        expect( pool_type.code ).to eq( '50' )
      end
      it "returns 25 pool type for 14101 meeting (Parma CSI)" do
        fix_meeting = Meeting.find( 14101 )
        pool_type = fix_meeting.get_pool_type
        expect( pool_type.code ).to eq( '25' )
      end

      it "has a method to find out meeting events by pool type" do
        expect( subject ).to respond_to( :get_events_by_pool_types )
      end
      it "returns an array" do
        fix_meeting_50 = Meeting.find( 14105 )
        fix_meeting_25 = Meeting.find( 14101 )
        expect( subject.get_events_by_pool_types ).to be_a_kind_of( Array )
        expect( fix_meeting_50.get_events_by_pool_types ).to be_a_kind_of( Array )
        expect( fix_meeting_25.get_events_by_pool_types ).to be_a_kind_of( Array )
      end
      it "returns an array of events by pool types" do
        fix_meeting_50 = Meeting.find( 14105 )
        event_by_pool_types = fix_meeting_50.get_events_by_pool_types
        expect( event_by_pool_types.count ).to eq( 5 )
        event_by_pool_types.each do |event_by_pool_type|
          expect( event_by_pool_type ).to be_an_instance_of( EventsByPoolType )
        end
        fix_meeting_25 = Meeting.find( 14101 )
        event_by_pool_types = fix_meeting_25.get_events_by_pool_types
        expect( event_by_pool_types.count ).to eq( 5 )
        event_by_pool_types.each do |event_by_pool_type|
          expect( event_by_pool_type ).to be_an_instance_of( EventsByPoolType )
        end
      end

      describe "#get_meeting_date" do      
        it "has a method to find out meeting date" do
          expect( subject ).to respond_to( :get_meeting_date )
        end
        it "returns a string" do
          expect( subject.get_meeting_date ).to be_an_instance_of( String )
        end
      end
      
      describe "#meeting_date_to_iso" do      
        it "has a method to find out meeting date in iso format" do
          expect( subject ).to respond_to( :meeting_date_to_iso )
        end
        it "returns a string" do
          expect( subject.meeting_date_to_iso ).to be_an_instance_of( String )
        end
        it "returns a string containing the meeting date" do
          str_date = subject.get_meeting_date
          expect( subject.meeting_date_to_iso ).to eq( str_date.to_date.strftime( '%Y%m%d' ) )
        end
      end
      
      describe "#get_data_import_file_name" do      
        it "has a method to find out meeting data import file name" do
          expect( subject ).to respond_to( :get_data_import_file_name )
        end
        it "returns a string" do
          expect( subject.get_data_import_file_name ).to be_an_instance_of( String )
        end
        it "returns a string containing the meeting date" do
          str_date = subject.get_meeting_date
          expect( subject.get_data_import_file_name ).to include( str_date.to_date.strftime( '%Y%m%d' ) )
        end
        it "returns a string containing the meeting code" do
          expect( subject.get_data_import_file_name ).to include( subject.code )
        end
      end
    end      
  end
  #-- -------------------------------------------------------------------------
  #++
end
