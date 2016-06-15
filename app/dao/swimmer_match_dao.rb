# encoding: utf-8

=begin

= SwimmerMatchDAO
  - Goggles framework vers.:  4.00.859.20160312
  - author: Leega

 Utility class to get swimmer "match" data.

=== Members:
 - <tt>:swimmer_male_count</tt> => Count of male swimmers with result
 - <tt>:result_male_count_count</tt> => Count of male total results
 - <tt>:oldest_male_swimmer</tt> => Oldest male swimmer with result
 - <tt>:disqualified_male_count</tt> => Count of male disqualified results
 - <tt>:swimmer_female_count</tt> => Count of male swimmers with result
 - <tt>:result_female_count</tt> => Count of male total results
 - <tt>:oldest_female_swimmer</tt> => Oldest male swimmer with result
 - <tt>:disqualified_female_count</tt> => Count of female disqualified results

=end
class SwimmerMatchDAO
  class SwimmerMatchProgramDAO
    # These must be initialized on creation:
    attr_reader :description, :meeting, :event_type

    # These can be edited later on:
    attr_accessor :local_result, :visitor_result

    # Creates a new instance.
    # Note the ascending precision of the parameters, which allows to skip
    # the rarely used ones.
    #
    def initialize( local_result = nil, visitor_result = nil, description = nil, meeting = nil, event_type = nil )
      @description     = description
      @local_result    = local_result
      @visitor_result  = visitor_result
      @meeting         = meeting
      @event_type      = event_type
    end

    # Gets the description of the match result
    # If no alternative description returns the locale result one
    #
    def get_description
      if @description
        @description
      else
        @local_result ? "#{@local_result.get_full_name} - #{@visitor_result.get_full_name if @visitor_result}" : '?'
      end
    end

    # Gets the meeting of the match result
    # If no meeting set returns the locale result one
    #
    def get_meeting
      if @meeting
        @meeting
      else
        @local_result ? @local_result.meeting : '?'
      end
    end

    # Gets the event_type of the match result
    # If no event_type set returns the locale result one
    #
    def get_event_type
      if @event_type
        @event_type
      else
        @local_result ? @local_result.event_type : '?'
      end
    end

    # Gets the locale timing
    #
    def get_locale_timing
      @local_result.get_timing if @local_result
    end

    # Gets the visitor timing
    #
    def get_visitor_timing
      @visitor_result.get_timing if @visitor_result
    end
  end
  # ---------------------------------------------------------------------------

  class SwimmerMatchEventSumDAO
    # These must be initialized on creation:
    #attr_reader :event_type

    # These can be edited later on:
    attr_accessor :event_type, :wons_count, :losses_count, :neutrals_count

    # Creates a new instance.
    # Note the ascending precision of the parameters, which allows to skip
    # the rarely used ones.
    #
    def initialize( event_type, wons_count = 0, losses_count = 0, neutrals_count = 0 )
      unless event_type && event_type.instance_of?( EventType )
        raise ArgumentError.new("Swimmer match event summary needs a valid event type")
      end

      @event_type     = event_type
      @wons_count     = wons_count
      @losses_count   = losses_count
      @neutrals_count = neutrals_count
    end

    # Increments the given summary voice
    #
    def increment( summary )
      case summary
      when :wons
        @wons_count += 1
      when :losses
        @losses_count += 1
      else
        @neutrals_count += 1
      end
    end
  end
  # ---------------------------------------------------------------------------

  # These must be initialized on creation:
  attr_reader :locale, :visitor

  # These can be edited later on:
  attr_accessor :wons, :losses, :neutrals, :events_summary, :first_meeting, :last_meeting

  # Creates a new instance.
  # Note the ascending precision of the parameters, which allows to skip
  # the rarely used ones.
  #
  def initialize
    @locale         = nil
    @visitor        = nil
    @wons           = []
    @losses         = []
    @neutrals       = []
    @events_summary = []
    @first_meeting  = nil
    @last_meeting   = nil
  end
  # ---------------------------------------------------------------------------

  # Sets the locale swimmer
  #
  def set_locale( local_swimmer )
    @locale = local_swimmer if local_swimmer && local_swimmer.instance_of?( Swimmer )
  end
  # ---------------------------------------------------------------------------

  # Sets the visitor swimmer
  #
  def set_visitor( visitor_swimmer )
    @visitor = visitor_swimmer if visitor_swimmer && visitor_swimmer.instance_of?( Swimmer )
  end
  # ---------------------------------------------------------------------------

  # Gets the locale swimmer
  #
  def get_locale
    @locale
  end
  # ---------------------------------------------------------------------------

  # Gets the locale swimmer
  #
  def get_visitor
    @visitor
  end
  # ---------------------------------------------------------------------------

  # Gets the wons matches count
  #
  def get_wons_count
    @wons.size
  end
  # ---------------------------------------------------------------------------

  # Gets the losses matches count
  #
  def get_losses_count
    @losses.size
  end
  # ---------------------------------------------------------------------------

  # Gets the neutrals matches count
  #
  def get_neutrals_count
    @neutrals.size
  end
  # ---------------------------------------------------------------------------

  # Gets the total matches count
  #
  def get_matches_count
    get_wons_count + get_losses_count + get_neutrals_count
  end
  # ---------------------------------------------------------------------------

  # Add a couple of results in the appropriate collection
  #   If locale better than visitor add to the wons
  #   if locale worst than visitor add to the losses
  #   else add to the neutrals
  # Returns the matche count
  #
  # If locale result already present, nothing done
  #
  # If results not valid nothing is done and returns -1
  #
  def add_match( local_result, visitor_result, description = nil, meeting = nil, event_type = nil )
    # Check if results are valids
    if local_result &&
     local_result.instance_of?( MeetingIndividualResult ) &&
     local_result.swimmer == @locale &&
     visitor_result &&
     visitor_result.instance_of?( MeetingIndividualResult ) &&
     visitor_result.swimmer == @visitor
      locale_timing  = local_result.is_disqualified ? 999999999999 : local_result.get_timing_instance.to_hundreds
      visitor_timing = visitor_result.is_disqualified ? 999999999999 : visitor_result.get_timing_instance.to_hundreds

      meeting = local_result.meeting if meeting == nil
      event_type = local_result.event_type if event_type == nil

      # Populate first and last meetings
      @first_meeting = meeting if @first_meeting == nil || @first_meeting.get_meeting_date.to_date > meeting.get_meeting_date.to_date
      @last_meeting = meeting if @last_meeting == nil || @last_meeting.get_meeting_date.to_date < meeting.get_meeting_date.to_date

      match = SwimmerMatchProgramDAO.new( local_result, visitor_result, description, meeting, event_type )

      # Verify reults timing
      # locale better than visitor
      if locale_timing < visitor_timing
        matches = add_match_to_collection( match, @wons, event_type, :wons )
      elsif locale_timing > visitor_timing
        matches = add_match_to_collection( match, @losses, event_type, :losses )
      else
        matches = add_match_to_collection( match, @neutrals, event_type, :neutrals )
      end
      matches > 0 ? get_matches_count : matches
    else
      -1
    end
  end

  private

  # Adds a program DAO to a give collection
  # Retruns 0 if already present
  # Returns the collectyion matches number if added
  #
  def add_match_to_collection( match, collection, event_type, summary )
    if collection.rindex{ |e| e.local_result == match.local_result && e.visitor_result == match.visitor_result }
      0
    else
      # Handle event summary
      event = @events_summary.rindex{ |e| e.event_type == event_type }
      if event
        @events_summary[event].increment( summary )
      else
        event_summary = SwimmerMatchEventSumDAO.new( event_type )
        event_summary.increment( summary )
        @events_summary << event_summary
      end

      collection << match
      collection.count
    end
  end
end
