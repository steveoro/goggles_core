require 'spec_helper'

describe SwimmerMatchEvaluator, :type => :model do

  let( :swimmer )         { create( :swimmer ) }
  let( :older_swimmer )   { create( :swimmer, year_of_birth: swimmer.year_of_birth - ( (rand * 4).to_i ), gender_type: swimmer.gender_type ) }
  let( :younger_swimmer ) { create( :swimmer, year_of_birth: swimmer.year_of_birth + ( (rand * 4).to_i ), gender_type: swimmer.gender_type ) }
  let( :fix_event )       { EventType.are_not_relays.order('RAND()').first }

  before(:all) do
    @leega   = Swimmer.find(23)
    @steve   = Swimmer.find(142)
    @cavallo = Swimmer.find(1025)
  end  
  
  subject { SwimmerMatchEvaluator.new( swimmer ) }

  describe "[a well formed instance]" do
    it "local_swimmer is the one used in costruction" do
      expect( subject.local_swimmer ).to eq( swimmer )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#set_visitor" do
    it "responds to #set_visitor" do
      expect( subject ).to respond_to( :set_visitor )
    end
    it "sets the visitor swimmer if a valid swimmer given" do
      expect( subject.visitor_swimmer ).to be nil
      expect( subject.set_visitor( swimmer ) ).to be true
      expect( subject.visitor_swimmer ).to eq( swimmer )
    end
    it "sets the visitor swimmer if a valid younger swimmer given" do
      expect( subject.visitor_swimmer ).to be nil
      expect( subject.set_visitor( younger_swimmer ) ).to be true
      expect( subject.visitor_swimmer ).to eq( younger_swimmer )
    end
    it "sets the visitor swimmer if a valid older swimmer given" do
      expect( subject.visitor_swimmer ).to be nil
      expect( subject.set_visitor( older_swimmer ) ).to be true
      expect( subject.visitor_swimmer ).to eq( older_swimmer )
    end
    it "doesn't set visitor swimmer if wrong swimmer parameter" do
      too_old_swimmer = create( :swimmer, year_of_birth: swimmer.year_of_birth - ( (rand * 20).to_i + 5 ) )
      too_young_swimmer = create( :swimmer, year_of_birth: swimmer.year_of_birth + ( (rand * 5).to_i + 5 ) )
      wrong_gender_swimmer = create( :swimmer, year_of_birth: swimmer.year_of_birth )
      wrong_gender_swimmer.gender_type = swimmer.gender_type.code == 'M' ? GenderType.find_by_code('F') : GenderType.find_by_code('M')
      expect( subject.visitor_swimmer ).to be nil
      expect( subject.set_visitor( 'wrong_parameter' ) ).to be false
      expect( subject.set_visitor( too_young_swimmer ) ).to be false
      expect( subject.set_visitor( too_old_swimmer ) ).to be false
      expect( subject.set_visitor( wrong_gender_swimmer ) ).to be false
      expect( subject.visitor_swimmer ).to be nil
    end   
  end
  #-- -------------------------------------------------------------------------

  describe "#has_matches?" do
    it "responds to #has_matches?" do
      expect( subject ).to respond_to( :has_matches? )
    end
    it "returns false if locale and visitor have never swam in the same program" do
      create( :meeting_individual_result, swimmer: swimmer )
      subject.set_visitor( younger_swimmer )
      expect( subject.local_swimmer ).not_to eq( subject.visitor_swimmer )
      expect( subject.local_swimmer.meeting_individual_results.count ).to be > 0
      expect( subject.visitor_swimmer.meeting_individual_results.count ).to be >= 0
      expect( subject.has_matches? ).to be false
    end
    it "returns true if locale and visitor are the same swimmer" do
      create( :meeting_individual_result, swimmer: swimmer )
      subject.set_visitor( swimmer )
      expect( subject.local_swimmer ).to eq( subject.visitor_swimmer )
      expect( subject.local_swimmer.meeting_individual_results.count ).to be > 0
      expect( subject.has_matches? ).to be true
    end
    it "returns false for Leega and Cavallo" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.visitor_swimmer = @cavallo
      expect( sme.has_matches? ).to be false
    end
    it "returns false for Leega and Cavallo forcing Cavallo" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      expect( sme.has_matches?( @cavallo ) ).to be false
    end
    it "returns true for Leega and Steve" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      expect( sme.has_matches? ).to be true
    end
    it "returns true for Leega and Steve forcing Steve" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      expect( sme.has_matches?( @steve ) ).to be true
    end
  end
  #-- -------------------------------------------------------------------------

  describe "#has_matches_on_event?" do
    it "responds to #has_matches?" do
      expect( subject ).to respond_to( :has_matches_on_event? )
    end
    it "returns false if locale and visitor have never swam in the same program" do
      create( :meeting_individual_result, swimmer: swimmer )
      subject.set_visitor( younger_swimmer )
      expect( subject.local_swimmer ).not_to eq( subject.visitor_swimmer )
      expect( subject.local_swimmer.meeting_individual_results.count ).to be > 0
      expect( subject.visitor_swimmer.meeting_individual_results.count ).to be >= 0
      expect( subject.has_matches_on_event?( fix_event ) ).to be false
    end
    it "returns true if locale and visitor are the same swimmer" do
      mir = create( :meeting_individual_result, swimmer: swimmer )
      subject.set_visitor( swimmer )
      expect( subject.local_swimmer ).to eq( subject.visitor_swimmer )
      expect( subject.local_swimmer.meeting_individual_results.count ).to be > 0
      expect( subject.has_matches_on_event?( mir.event_type ) ).to be true
    end
    it "returns false for Leega and Cavallo" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.visitor_swimmer = @cavallo
      expect( subject.has_matches_on_event?( fix_event ) ).to be false
    end
    it "returns true for Leega and Steve on 100MI, 50FA and 100SL" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      expect( sme.has_matches_on_event?( EventType.find_by_code( '100MI' ) ) ).to be true
      expect( sme.has_matches_on_event?( EventType.find_by_code( '50FA' ) ) ).to be true
      expect( sme.has_matches_on_event?( EventType.find_by_code( '100SL' ) ) ).to be true
    end
    it "returns false for Leega and Steve on 400MI and 1500SL" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      expect( sme.has_matches_on_event?( EventType.find_by_code( '400MI' ) ) ).to be false
      expect( sme.has_matches_on_event?( EventType.find_by_code( '1500SL' ) ) ).to be false
    end
  end
  #-- -------------------------------------------------------------------------

  describe "#get_matches" do
    it "responds to #get_matches" do
      expect( subject ).to respond_to( :get_matches )
    end
    it "returns all swimmer meeting programs for same swimmer" do
      create_list( :meeting_individual_result, ( rand * 15 ).to_i + 1, swimmer: swimmer )
      subject.set_visitor( swimmer )
      matches = subject.get_matches
      expect( matches ).to be_an_instance_of( ActiveRecord::Relation )
      expect( matches.count ).to be > 0
      expect( matches ).to all( be_an_instance_of( MeetingProgram ) )
      expect( matches.count ).to eq( swimmer.meeting_programs.count )
    end
    it "returns nil if no matches" do
      subject.set_visitor( older_swimmer )
      expect( subject.has_matches? ).to be false
      expect( subject.get_matches ).to be nil
    end
    it "returns a set of meeting programs for Leega and Steve including 50FA, 100MI and 100SL and doesn't includes 400MI and 1500SL" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      matches = sme.get_matches
      expect( matches ).to be_an_instance_of( ActiveRecord::Relation )
      expect( matches.count ).to be > 0
      expect( matches ).to all( be_an_instance_of( MeetingProgram ) )
      events = matches.map{ |mp| mp.event_type.code }.uniq
      expect( events ).to include( '50FA' )      
      expect( events ).to include( '100SL' )      
      expect( events ).to include( '100MI' )      
      expect( events ).not_to include( '400MI' )      
      expect( events ).not_to include( '1500SL' )      
    end
  end
  #-- -------------------------------------------------------------------------

  describe "#get_matches_on_event" do
    it "responds to #get_matches_on_event" do
      expect( subject ).to respond_to( :get_matches_on_event )
    end
    it "returns nil if no matches" do
      subject.set_visitor( older_swimmer )
      expect( subject.has_matches_on_event?( fix_event ) ).to be false
      expect( subject.get_matches_on_event( fix_event ) ).to be nil
    end
    it "returns nil if no matches of given event type" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      expect( sme.has_matches? ).to be true
      expect( sme.has_matches_on_event?( EventType.find_by_code( '400MI' ) ) ).to be false
      expect( sme.get_matches_on_event( EventType.find_by_code( '400MI' ) ) ).to be nil
      expect( sme.has_matches_on_event?( EventType.find_by_code( '1500SL' ) ) ).to be false
      expect( sme.get_matches_on_event( EventType.find_by_code( '1500SL' ) ) ).to be nil
    end
    it "returns a set of meeting programs for Leega and Steve including only given event type" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      matches = sme.get_matches_on_event( EventType.find_by_code( '100MI' ) )
      expect( matches ).to be_an_instance_of( ActiveRecord::Relation )
      expect( matches.count ).to be > 0
      expect( matches ).to all( be_an_instance_of( MeetingProgram ) )
      events = matches.map{ |mp| mp.event_type.code }.uniq
      expect( events.count ).to eq( 1 )
      expect( events ).to include( '100MI' )      
      expect( events ).not_to include( '50FA' )      
      expect( events ).not_to include( '100SL' )      
      matches = sme.get_matches_on_event( EventType.find_by_code( '100SL' ) )
      expect( matches ).to be_an_instance_of( ActiveRecord::Relation )
      expect( matches.count ).to be > 0
      expect( matches ).to all( be_an_instance_of( MeetingProgram ) )
      events = matches.map{ |mp| mp.event_type.code }.uniq
      expect( events.count ).to eq( 1 )
      expect( events ).to include( '100SL' )      
      expect( events ).not_to include( '50FA' )      
      expect( events ).not_to include( '100MI' )      
      matches = sme.get_matches_on_event( EventType.find_by_code( '50FA' ) )
      expect( matches ).to be_an_instance_of( ActiveRecord::Relation )
      expect( matches.count ).to be > 0
      expect( matches ).to all( be_an_instance_of( MeetingProgram ) )
      events = matches.map{ |mp| mp.event_type.code }.uniq
      expect( events.count ).to eq( 1 )
      expect( events ).to include( '50FA' )      
      expect( events ).not_to include( '100MI' )      
      expect( events ).not_to include( '100SL' )      
    end
  end
  #-- -------------------------------------------------------------------------

  describe "#matches_to_dao" do
    it "responds to #matches_to_dao" do
      expect( subject ).to respond_to( :matches_to_dao )
    end
    it "returns nil if no visitor swimmer" do
      expect( subject.matches_to_dao ).to be nil
    end
    it "returns a SwimmerMatchDAO if visitor swimmer set" do
      expect( subject.set_visitor( swimmer ) ).to be true
      expect( subject.matches_to_dao ).to be_an_instance_of( SwimmerMatchDAO )
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      expect( sme.matches_to_dao ).to be_an_instance_of( SwimmerMatchDAO )
      sme.visitor_swimmer = @cavallo
      expect( sme.matches_to_dao ).to be_an_instance_of( SwimmerMatchDAO )
    end
    it "returns a SwimmerMatchDAO with no matches set if no matches for swimmers" do
      expect( subject.set_visitor( younger_swimmer ) ).to be true
      dao = subject.matches_to_dao
      expect( dao.get_matches_count ).to eq( 0 )
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.visitor_swimmer = @cavallo
      dao = sme.matches_to_dao
      expect( dao.get_matches_count ).to eq( 0 )
    end
    it "returns a SwimmerMatchDAO with matches set if some matches for swimmers" do
      create_list( :meeting_individual_result, ( rand * 15 ).to_i + 1, swimmer: swimmer )
      expect( subject.set_visitor( swimmer ) ).to be true
      dao = subject.matches_to_dao
      expect( dao.get_matches_count ).to be > 0
      expect( dao.get_matches_count ).to eq( swimmer.meeting_individual_results.count )
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      matches = sme.get_matches
      dao = sme.matches_to_dao
      expect( dao.get_matches_count ).to be > 0
      expect( dao.get_matches_count ).to eq( matches.count )
    end
    it "returns a SwimmerMatchDAO with only neutrals if same swimmer" do
      create_list( :meeting_individual_result, ( rand * 15 ).to_i + 1, swimmer: swimmer )
      expect( subject.set_visitor( swimmer ) ).to be true
      dao = subject.matches_to_dao
      expect( dao.get_wons_count ).to eq( 0 )
      expect( dao.get_losses_count ).to eq( 0 )
      expect( dao.get_neutrals_count ).to be > 0
      expect( dao.get_neutrals_count ).to eq( swimmer.meeting_individual_results.count )
    end
    it "returns a SwimmerMatchDAO with wins, losses and neutrals for Leega and Steve" do
      sme = SwimmerMatchEvaluator.new( @leega ) 
      sme.set_visitor( @steve )
      dao = sme.matches_to_dao
      expect( dao.get_wons_count ).to be > 0
      expect( dao.get_losses_count ).to be > 0
      expect( dao.get_neutrals_count ).to be > 0
    end
  end
  #-- -------------------------------------------------------------------------

  context "not a valid instance" do   
    it "raises an exception for wrong swimmer parameter" do
      expect{ SwimmerMatchEvaluator.new() }.to raise_error( ArgumentError )
      expect{ SwimmerMatchEvaluator.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
    end   
  end
  #-- -------------------------------------------------------------------------
  #++
end
