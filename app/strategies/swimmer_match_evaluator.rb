# encoding: utf-8

=begin

= SwimmerMatchEvaluator
  - Goggles framework vers.:  4.00.857
  - author: Leega

 Utility class to evaluate swimmers match
 A swimmers match is a meeting program in which the target swimmers have competed
 Return data in SwimmerMatchDAO format
 Locale swimmer is the swimmer who request the evaluation
 Visitor swimmer is the target swimmer to be evaluated 

=end
class SwimmerMatchEvaluator
  # These must be initialized on creation:
  attr_reader :local_swimmer

  # These can be edited later on:
  attr_accessor :visitor_swimmer 

  # Creates a new instance.
  # Note the ascending precision of the parameters, which allows to skip
  # the rarely used ones.
  #
  def initialize( local_swimmer )
    unless local_swimmer && local_swimmer.instance_of?( Swimmer )
      raise ArgumentError.new("Swimmer match evaluation needs a valid locale swimmer")
    end

    @local_swimmer  = local_swimmer 
    @visitor_swimmer = nil
    @matches         = [] 
  end
  
  # Sets the target visitor swimmer
  # The visitor swimmer shuld be of the same gender of locale
  # and the year of birth difference should be < 5
  #
  # Returns true if visitor swimmer set
  #
  def set_visitor( visitor_swimmer )
    if visitor_swimmer && 
     visitor_swimmer.instance_of?( Swimmer ) &&
     visitor_swimmer.gender_type == @local_swimmer.gender_type &&
     (visitor_swimmer.year_of_birth - @local_swimmer.year_of_birth).abs < 5  
      @visitor_swimmer = visitor_swimmer
      true
    else
      false
    end
  end

  # Search if locale and visitor swimmer has ever swam in the
  # same meeting_program
  #
  def has_matches?( visitor_swimmer = @visitor_swimmer )
    @local_swimmer.meeting_programs.count > 0 &&
     visitor_swimmer && visitor_swimmer.id &&
     @local_swimmer.meeting_programs.where(['exists (select 1 from meeting_individual_results mir join swimmers s on s.id = mir.swimmer_id where s.id = ? and mir.meeting_program_id = meeting_programs.id)', visitor_swimmer.id]).count > 0
  end
  
  # Search if locale and visitor swimmer has ever swam in the
  # same meeting_program for a given event type
  #
  def has_matches_on_event?( event_type, visitor_swimmer = @visitor_swimmer )
    @local_swimmer.meeting_programs.count > 0 &&
     visitor_swimmer && visitor_swimmer.id &&
     @local_swimmer.meeting_programs.includes( :meeting_event ).where(['meeting_events.event_type_id = ? and exists (select 1 from meeting_individual_results mir join swimmers s on s.id = mir.swimmer_id where s.id = ? and mir.meeting_program_id = meeting_programs.id)', event_type.id, visitor_swimmer.id]).count > 0
  end
  
  # Scan for meeting_programs in which locale and visitor are
  # all present
  #
  def get_matches
    @matches = @local_swimmer.meeting_programs.sort_by_date( 'DESC' ).includes( :meeting, :event_type ).where(['exists (select 1 from meeting_individual_results mir join swimmers s on s.id = mir.swimmer_id where s.id = ? and mir.meeting_program_id = meeting_programs.id)', @visitor_swimmer.id]) if has_matches?
  end
  
  # Scan for meeting_programs in which locale and visitor are
  # all present for given event_types
  #
  def get_matches_on_event( event_type )
    @matches = @local_swimmer.meeting_programs.sort_by_date( 'DESC' ).includes( :meeting, :event_type ).where(['meeting_events.event_type_id = ? and exists (select 1 from meeting_individual_results mir join swimmers s on s.id = mir.swimmer_id where s.id = ? and mir.meeting_program_id = meeting_programs.id)', event_type.id, visitor_swimmer.id]) if has_matches_on_event?( event_type )
  end
  
  # Returns a DAO structure fotr matches handling
  # containing the matche previously found
  # If matches nt found already found, will find it
  # If not visitor swimmer set returns nil
  #
  def matches_to_dao
    if @visitor_swimmer
      get_matches if @matches.count == 0
      
      sme_dao = SwimmerMatchDAO.new()
      sme_dao.set_locale( @local_swimmer )
      sme_dao.set_visitor( @visitor_swimmer )
      
      # Assumes in the same meeting program a swimmer should has only one result
      # In any case it will consider the best one if more than one
      @matches.each do |meeting_program|
        local_result = @local_swimmer.meeting_individual_results.where( meeting_program: meeting_program ).sort_by_timing.first 
        visitor_result = @visitor_swimmer.meeting_individual_results.where( meeting_program: meeting_program ).sort_by_timing.first
        sme_dao.add_match( local_result, visitor_result, nil, meeting_program.meeting, meeting_program.event_type ) 
      end
      
      sme_dao
    else
      nil
    end
  end
end
