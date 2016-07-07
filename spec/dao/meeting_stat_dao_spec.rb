require 'rails_helper'

shared_examples_for "(existance of a member array of hashes)" do |member_name_array|
  member_name_array.each do |member_name|
    it "responds to ##{member_name}" do
      expect( subject ).to respond_to( member_name )
    end

    it "has a ##{member_name} array" do
      expect( subject.send(member_name.to_sym) ).to be_a_kind_of( Array )
    end
  end
end


describe MeetingStatDAO, :type => :model do
  
  # Pre-loaded seeded last CSI seasons
  before(:all) do
    @seeded_meets = [12101, 12102, 12103, 12104, 12105, 13101, 13102, 13103, 13104, 13105, 13106]
  end
  
  let( :meeting )              { Meeting.find( @seeded_meets.at( (rand * @seeded_meets.size).to_i ) ) }

  context "TeamMeetingStatDAO subclass," do
    
    let( :team )               { meeting.teams.at( ( rand * meeting.teams.count ).to_i ) }

    subject { MeetingStatDAO::TeamMeetingStatDAO.new( team ) }
  
    describe "[a well formed instance]" do
      it "team is the one used in costruction" do
        expect( subject.team ).to eq( team )
      end

      it_behaves_like( "(the existance of a method returning numeric values)", [
        :male_entries,       :female_entries, 
        :male_ent_swimmers,  :female_ent_swimmers,
        :male_results,       :female_results,
        :male_swimmers,      :female_swimmers,
        :male_best,          :female_best,
        :male_worst,         :female_worst,
        :male_average,       :female_average,
        :male_disqualifieds, :female_disqualifieds,
        :male_golds,         :female_golds,
        :male_silvers,       :female_silvers,
        :male_bronzes,       :female_bronzes,
        :relay_results,
        :relay_disqualifieds,
        :relay_golds,
        :relay_silvers,
        :relay_bronzes
      ])
    end
    #-- -------------------------------------------------------------------------

    describe "#get_entries_count" do
      it "returns sum of male and female entries count" do
        subject.male_entries = (rand * 100).to_i
        subject.female_entries = (rand * 100).to_i
        expect(subject.get_entries_count).to eq(subject.male_entries + subject.female_entries)
      end
    end

    describe "#get_ent_swimmers_count" do
      it "returns sum of male and female entered swimmers count" do
        subject.male_ent_swimmers = (rand * 100).to_i
        subject.female_ent_swimmers = (rand * 100).to_i
        expect(subject.get_ent_swimmers_count).to eq(subject.male_ent_swimmers + subject.female_ent_swimmers)
      end
    end

    describe "#get_results_count" do
      it "returns sum of male and female results count" do
        subject.male_results = (rand * 100).to_i
        subject.female_results = (rand * 100).to_i
        expect(subject.get_results_count).to eq(subject.male_results + subject.female_results)
      end
    end

    describe "#get_swimmers_count" do
      it "returns sum of male and female swimmers count" do
        subject.male_swimmers = (rand * 100).to_i
        subject.female_swimmers = (rand * 100).to_i
        expect(subject.get_swimmers_count).to eq(subject.male_swimmers + subject.female_swimmers)
      end
    end

    describe "#get_disqualifieds_count" do
      it "returns sum of male and female disqualifieds count" do
        subject.male_disqualifieds = (rand * 100).to_i
        subject.female_disqualifieds = (rand * 100).to_i
        subject.relay_disqualifieds = (rand * 100).to_i
        expect(subject.get_disqualifieds_count).to eq(subject.male_disqualifieds + subject.female_disqualifieds + subject.relay_disqualifieds)
      end
    end

    describe "#get_golds_count" do
      it "returns sum of males, females and relays golds count" do
        subject.male_golds = (rand * 100).to_i
        subject.female_golds = (rand * 100).to_i
        subject.relay_golds = (rand * 100).to_i
        expect(subject.get_golds_count).to eq(subject.male_golds + subject.female_golds + subject.relay_golds)
      end
    end

    describe "#get_silvers_count" do
      it "returns sum of males, females and relays silvers count" do
        subject.male_silvers = (rand * 100).to_i
        subject.female_silvers = (rand * 100).to_i
        subject.relay_silvers = (rand * 100).to_i
        expect(subject.get_silvers_count).to eq(subject.male_silvers + subject.female_silvers + subject.relay_silvers)
      end
    end

    describe "#get_bronzes_count" do
      it "returns sum of males, females and relays bronzes count" do
        subject.male_bronzes = (rand * 100).to_i
        subject.female_bronzes = (rand * 100).to_i
        subject.relay_bronzes = (rand * 100).to_i
        expect(subject.get_bronzes_count).to eq(subject.male_bronzes + subject.female_bronzes + subject.relay_bronzes)
      end
    end

    describe "#get_medals_count" do
      it "returns sum of males, females and relays golds, silver and bronzes count" do
        subject.male_golds = (rand * 100).to_i
        subject.female_golds = (rand * 100).to_i
        subject.relay_golds = (rand * 100).to_i
        subject.male_silvers = (rand * 100).to_i
        subject.female_silvers = (rand * 100).to_i
        subject.relay_silvers = (rand * 100).to_i
        subject.male_bronzes = (rand * 100).to_i
        subject.female_bronzes = (rand * 100).to_i
        subject.relay_bronzes = (rand * 100).to_i
        expect(subject.get_medals_count).to eq(subject.get_golds_count + subject.get_silvers_count + subject.get_bronzes_count)
      end
    end
    #-- -------------------------------------------------------------------------

    context "not a valid instance" do   
      it "raises an exception for wrong meeting parameter" do
        expect{ MeetingStatDAO::TeamMeetingStatDAO.new() }.to raise_error( ArgumentError )
        expect{ MeetingStatDAO::TeamMeetingStatDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
      end   
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
  
  context "CategoryMeetingStatDAO subclass," do
    
    let( :category_type )         { meeting.season.category_types.at( ( rand * meeting.season.category_types.count ).to_i ) }

    subject { MeetingStatDAO::CategoryMeetingStatDAO.new( category_type ) }
  
    describe "[a well formed instance]" do
      it "category type is the one used in costruction" do
        expect( subject.category_type ).to eq( category_type )
      end

      it_behaves_like( "(the existance of a method returning numeric values)", [
        :male_ent_swimmers, :female_ent_swimmers, 
        :male_swimmers,     :female_swimmers
      ])
    end
    #-- -------------------------------------------------------------------------

    describe "#get_ent_swimmers_count" do
      it "returns sum of male and female entered swimmers count" do
        subject.male_ent_swimmers = (rand * 100).to_i
        subject.female_ent_swimmers = (rand * 100).to_i
        expect(subject.get_ent_swimmers_count).to eq(subject.male_ent_swimmers + subject.female_ent_swimmers)
      end
    end

    describe "#get_swimmers_count" do
      it "returns sum of male and female swimmers count" do
        subject.male_swimmers = (rand * 100).to_i
        subject.female_swimmers = (rand * 100).to_i
        expect(subject.get_swimmers_count).to eq(subject.male_swimmers + subject.female_swimmers)
      end
    end
    #-- -------------------------------------------------------------------------

    context "not a valid instance" do   
      it "raises an exception for wrong category parameter" do
        expect{ MeetingStatDAO::CategoryMeetingStatDAO.new() }.to raise_error( ArgumentError )
        expect{ MeetingStatDAO::CategoryMeetingStatDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
      end   
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
  
  context "EventMeetingStatDAO subclass," do
    
    let( :event_type )         { meeting.event_types.at( ( rand * meeting.event_types.count ).to_i ) }

    subject { MeetingStatDAO::EventMeetingStatDAO.new( event_type ) }
  
    describe "[a well formed instance]" do
      it "event type is the one used in costruction" do
        expect( subject.event_type ).to eq( event_type )
      end

      it_behaves_like( "(the existance of a method returning numeric values)", [
        :male_entries,       :female_entries, 
        :male_results,       :female_results
      ])
    end
    #-- -------------------------------------------------------------------------

    describe "#get_entries_count" do
      it "returns sum of male and female entries count" do
        subject.male_entries = (rand * 100).to_i
        subject.female_entries = (rand * 100).to_i
        expect(subject.get_entries_count).to eq(subject.male_entries + subject.female_entries)
      end
    end

    describe "#get_results_count" do
      it "returns sum of male and female results count" do
        subject.male_results = (rand * 100).to_i
        subject.female_results = (rand * 100).to_i
        expect(subject.get_results_count).to eq(subject.male_results + subject.female_results)
      end
    end
    #-- -------------------------------------------------------------------------

    context "not a valid instance" do   
      it "raises an exception for wrong event parameter" do
        expect{ MeetingStatDAO::EventMeetingStatDAO.new() }.to raise_error( ArgumentError )
        expect{ MeetingStatDAO::EventMeetingStatDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
      end   
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
  
  subject { MeetingStatDAO.new( meeting ) }

  describe "[a well formed instance]" do
    it "meeting is the one used in costruction" do
      expect( subject.meeting ).to eq( meeting )
    end

    it "has a valid meeting instance" do
      expect(subject.get_meeting).to be_an_instance_of( Meeting )
    end

    it "responds to generals" do
      expect( subject ).to respond_to( :generals )
    end

    it "has a generals hash" do
      expect( subject.generals ).to be_a_kind_of( Hash )
    end

    it_behaves_like( "(existance of a member array of hashes)", [
      :teams,
      :categories,
      :events
    ])

    describe "#get_general" do
      it "respondo to #get_general" do
        expect( subject ).to respond_to( :get_general )
      end
      it "returns a value if parameter corrisponding to a valid key" do
        valid_key = :teams_count
        expect( subject.generals.has_key?( valid_key ) ).to be true
        expect( subject.get_general( valid_key ) ).not_to be_nil
      end
      it "returns nil if parameter not corrisponding to a valid key" do
        expect( subject.get_general( :wrong_key ) ).to be_nil
      end
      it "returns a not nil value for each general valid key" do
        subject.generals.keys.each do |valid_key|
          expect( subject.get_general( valid_key ) ).not_to be_nil
        end
      end
    end

    describe "#set_general" do
      it "respondo to #set_general" do
        expect( subject ).to respond_to( :set_general )
      end
      it "sets the given value to the parameter if parameter corrisponding to a valid key" do
        valid_key = :teams_count
        value     = ( rand * 100 ).to_i
        expect( subject.generals.has_key?( valid_key ) ).to be true
        expect( subject.get_general( valid_key ) ).to eq( 0 )
        subject.set_general( valid_key, value )
        expect( subject.get_general( valid_key ) ).to eq( value )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#get_entered_swimmers_count" do
    it "returns sum of male and female entered swimmers count" do
      subject.set_general( :ent_swimmers_male_count, (rand * 100).to_i )
      subject.set_general( :ent_swimmers_female_count, (rand * 100).to_i )
      expect(subject.get_entered_swimmers_count).to eq(subject.ent_swimmers_male_count + subject.ent_swimmers_female_count)
    end
  end

  describe "#get_entries_count" do
    it "returns sum of male and female entries count" do
      subject.set_general( :ent_entries_male_count, (rand * 100).to_i )
      subject.set_general( :ent_entries_female_count, (rand * 100).to_i )
      expect(subject.get_entries_count).to eq(subject.entries_male_count + subject.entries_female_count)
    end
  end

  describe "#get swimmers_count" do
    it "returns sum of male and female swimmers count" do
      subject.set_general( :swimmers_male_count, (rand * 100).to_i )
      subject.set_general( :swimmers_female_count, (rand * 100).to_i )
      expect(subject.get_swimmers_count).to eq(subject.swimmers_male_count + subject.swimmers_female_count)
    end
  end

  describe "#get_results_count" do
    it "returns sum of male and female results count" do
      subject.set_general( :results_male_count, (rand * 100).to_i )
      subject.set_general( :results_female_count, (rand * 100).to_i )
      expect(subject.get_results_count).to eq(subject.results_male_count + subject.results_female_count)
    end
  end

  describe "#get_disqualifieds_count" do
    it "returns sum of male and female results count" do
      subject.set_general( :disqualifieds_male_count, (rand * 100).to_i )
      subject.set_general( :disqualifieds_female_count, (rand * 100).to_i )
      expect(subject.get_disqualifieds_count).to eq(subject.dsqs_male_count + subject.dsqs_female_count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "not a valid instance" do   
    it "raises an exception for wrong meeting parameter" do
      expect{ MeetingStatDAO.new() }.to raise_error( ArgumentError )
      expect{ MeetingStatDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
    end   
  end
  #-- -------------------------------------------------------------------------
  #++
end
