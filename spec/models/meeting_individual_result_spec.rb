require 'rails_helper'


describe MeetingIndividualResult, :type => :model do
  it_behaves_like "SwimmerRelatable"
  it_behaves_like "TimingGettable"
  #-- -------------------------------------------------------------------------
  #++


  context "[scope]" do
    describe "self.sort_by_event_order" do
      it "does not raise any errors (for ASC sorting)" do
        expect{
          # [Steve, 20180614] Let's choose a meeting w/o too many MIRs and test this scope:
          Meeting.find(17105).meeting_individual_results.sort_by_event_order.count
        }.not_to raise_error
      end
      it "does not raise any errors (for DESC sorting)" do
        expect{
          # [Steve, 20180614] Let's choose a meeting w/o too many MIRs and test this scope:
          Meeting.find(17105).meeting_individual_results.sort_by_event_order('DESC').count
        }.not_to raise_error
      end
    end

    describe "self.sort_by_event_and_timing" do
      it "does not raise any errors (for ASC sorting)" do
        expect{
          # [Steve, 20180614] Let's choose a meeting w/o too many MIRs and test this scope:
          Meeting.find(17105).meeting_individual_results.sort_by_event_and_timing.count
        }.not_to raise_error
      end
      it "does not raise any errors (for DESC sorting)" do
        expect{
          # [Steve, 20180614] Let's choose a meeting w/o too many MIRs and test this scope:
          Meeting.find(17105).meeting_individual_results.sort_by_event_and_timing('DESC').count
        }.not_to raise_error
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "[a well formed instance]" do

    # XXX Using pre-existing values to speed-up tests:
    subject { MeetingIndividualResult.limit(100).sample }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to an individual result" do
      expect( subject.meeting_program.event_type.is_a_relay ).to be false
    end

    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting_program,
      :team,
      :team_affiliation,
      :badge
    ])
    #:disqualification_code_type  # This field is optional so could be empty

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :is_valid,
      :is_male,
      :is_female,
      :is_disqualified,
      :is_not_disqualified,
      :is_personal_best,
      :has_rank,
      :for_event_by_pool_type,
      :for_pool_type,
      :for_season_type,
      :for_team,
      :sort_by_pool_and_event,
      :sort_by_gender_and_category
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name,
        :get_verbose_name,
        :get_event_by_pool_type_code
      ])
    end

    context "[methods used for selecting records]" do
      it_behaves_like( "(the existance of a method with parameters, returning boolean values)",
        [
          :has_pool_type_code?,
          :has_event_type_code?,
          :has_category_type_code?,
          :has_gender_type_code?,
          :has_federation_type_code?
        ],
        'fakecode'
      )
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_event_by_pool_type_code" do
      it "returns a string that contains event code" do
        expect( subject.get_event_by_pool_type_code ).to include( subject.event_type.code )
      end
      it "returns a string that contains pool code" do
        expect( subject.get_event_by_pool_type_code ).to include( subject.pool_type.code )
      end
      it "returns a string that contains '-' separator" do
        expect( subject.get_event_by_pool_type_code ).to include( '-' )
      end
      it "returns a valid event by pool type code corresponding to an existent event by pool type" do
        expect( EventsByPoolType.find_by_key( subject.get_event_by_pool_type_code ) ).to be_an_instance_of( EventsByPoolType )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_event_by_pool_type" do
      it "returns a valid event by pool type" do
        expect( subject.get_event_by_pool_type ).to be_an_instance_of( EventsByPoolType )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_passages" do
      it "returns a collection responding to :each" do
        expect( subject.get_passages ).to respond_to(:each)
      end
      it "returns a list of passages for the given result" do
        subject.get_passages.each do |element|
          expect( element ).to be_an_instance_of( Passage )
        end
      end
      it "returns a non-empty list of passages when passages are found" do
        fixture = create( :meeting_individual_result_with_passages )
        expect( fixture.get_passages.count ).to be > 0
      end
      it "returns a list of sorted passages" do
        fixture = create( :meeting_individual_result_with_passages )
        current_item_distance = 0
        fixture.get_passages.each do |item|
          expect(item.passage_type.length_in_meters).to be >= current_item_distance  # >= because the factory can create passages having same distance
          current_item_distance = item.passage_type.length_in_meters
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_swimmer_age" do
      it "returns a number" do
        expect( subject.get_swimmer_age ).to be > 0
      end
      it "returns the years between swimmer year of birth and meeting scheduled date" do
        year_of_birth = subject.swimmer.year_of_birth
        year_of_meeting = subject.get_scheduled_date.year
        expect( year_of_birth ).to be >= 1900
        expect( year_of_meeting ).to be > year_of_birth
        expect( subject.get_swimmer_age ).to be >= ( year_of_meeting - year_of_birth )
        expect( subject.get_swimmer_age ).to be <= ( year_of_meeting - year_of_birth ) + 1
      end
      it "returns the years between swimmer year of birth and meeting scheduled date considering meeting month" do
        year_of_birth = subject.swimmer.year_of_birth
        year_of_meeting = subject.get_scheduled_date.year
        if subject.get_scheduled_date.month > 9
          expect( subject.get_swimmer_age ).to eq( ( year_of_meeting - year_of_birth ) + 1 )
        else
          expect( subject.get_swimmer_age ).to eq( year_of_meeting - year_of_birth )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
