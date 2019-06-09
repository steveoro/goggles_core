# frozen_string_literal: true

#
# = MeetingStatDAO
#   - Goggles framework vers.:  4.00.175.20140210
#   - author: Leega
#
#  Utility class to get meeting stats from meeting results or entries.
#
# === Members:
#  - <tt>:swimmer_male_count</tt> => Count of male swimmers with result
#  - <tt>:result_male_count_count</tt> => Count of male total results
#  - <tt>:oldest_male_swimmer</tt> => Oldest male swimmer with result
#  - <tt>:disqualified_male_count</tt> => Count of male disqualified results
#  - <tt>:swimmer_female_count</tt> => Count of male swimmers with result
#  - <tt>:result_female_count</tt> => Count of male total results
#  - <tt>:oldest_female_swimmer</tt> => Oldest male swimmer with result
#  - <tt>:disqualified_female_count</tt> => Count of female disqualified results
#
class MeetingStatDAO

  class TeamMeetingStatDAO

    # These must be initialized on creation:
    attr_reader :team

    # These can be edited later on:
    attr_accessor :male_entries,       :female_entries,
                  :male_results,       :female_results,
                  :male_swimmers,      :female_swimmers,
                  :male_ent_swimmers,  :female_ent_swimmers,
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

    # Creates a new instance.
    # Note the ascending precision of the parameters, which allows to skip
    # the rarely used ones.
    #
    def initialize(team)
      raise ArgumentError, 'Team meeting stat needs a valid team' unless team&.instance_of?(Team)

      @team                 = team
      @male_entries         = 0
      @female_entries       = 0
      @male_ent_swimmers    = 0
      @female_ent_swimmers  = 0
      @male_results         = 0
      @female_results       = 0
      @male_swimmers        = 0
      @female_swimmers      = 0
      @male_best            = 0
      @male_worst           = 0
      @male_average         = 0
      @female_best          = 0
      @female_worst         = 0
      @female_average       = 0
      @male_disqualifieds   = 0
      @female_disqualifieds = 0
      @male_golds           = 0
      @male_silvers         = 0
      @male_bronzes         = 0
      @female_golds         = 0
      @female_silvers       = 0
      @female_bronzes       = 0
      @relay_results        = 0
      @relay_disqualifieds  = 0
      @relay_golds          = 0
      @relay_silvers        = 0
      @relay_bronzes        = 0
    end

    def get_entries_count
      @male_entries + @female_entries
    end

    def get_ent_swimmers_count
      @male_ent_swimmers + @female_ent_swimmers
    end

    def get_results_count
      @male_results + @female_results
    end

    def get_swimmers_count
      @male_swimmers + @female_swimmers
    end

    def get_disqualifieds_count
      @male_disqualifieds + @female_disqualifieds + @relay_disqualifieds
    end

    def get_golds_count
      @male_golds + @female_golds + @relay_golds
    end

    def get_silvers_count
      @male_silvers + @female_silvers + @relay_silvers
    end

    def get_bronzes_count
      @male_bronzes + @female_bronzes + @relay_bronzes
    end

    def get_medals_count
      get_golds_count + get_silvers_count + get_bronzes_count
    end

  end
  # ---------------------------------------------------------------------------

  class CategoryMeetingStatDAO

    # These must be initialized on creation:
    attr_reader :category_type

    # These can be edited later on:
    attr_accessor :male_ent_swimmers, :female_ent_swimmers,
                  :male_swimmers,     :female_swimmers

    # Creates a new instance.
    # Note the ascending precision of the parameters, which allows to skip
    # the rarely used ones.
    #
    def initialize(category_type)
      raise ArgumentError, 'Category meeting stat needs a valid category type' unless category_type&.instance_of?(CategoryType)

      @category_type        = category_type
      @male_ent_swimmers    = 0
      @female_ent_swimmers  = 0
      @male_swimmers        = 0
      @female_swimmers      = 0
    end

    def get_ent_swimmers_count
      @male_ent_swimmers + @female_ent_swimmers
    end

    def get_swimmers_count
      @male_swimmers + @female_swimmers
    end

  end
  # ---------------------------------------------------------------------------

  class EventMeetingStatDAO

    # These must be initialized on creation:
    attr_reader :event_type

    # These can be edited later on:
    attr_accessor :male_entries,       :female_entries,
                  :male_results,       :female_results

    # Creates a new instance.
    # Note the ascending precision of the parameters, which allows to skip
    # the rarely used ones.
    #
    def initialize(event_type)
      raise ArgumentError, 'Event meeting stat needs a valid event type' unless event_type&.instance_of?(EventType)

      @event_type           = event_type
      @male_entries         = 0
      @female_entries       = 0
      @male_results         = 0
      @female_results       = 0
    end

    def get_entries_count
      @male_entries + @female_entries
    end

    def get_results_count
      @male_results + @female_results
    end

  end
  # ---------------------------------------------------------------------------

  # These must be initialized on creation:
  attr_reader :meeting

  # These can be edited later on:
  attr_accessor :generals, :teams, :categories, :events

  # Creates a new instance.
  # Note the ascending precision of the parameters, which allows to skip
  # the rarely used ones.
  #
  def initialize(meeting)
    raise ArgumentError, 'Meeting stat needs a valid meeting' unless meeting&.instance_of?(Meeting)

    @meeting    = meeting
    @generals   = prepare_generals
    @teams      = []
    @categories = []
    @events     = []
  end
  # ---------------------------------------------------------------------------

  def get_meeting
    @meeting
  end
  # ---------------------------------------------------------------------------

  # Sum male and female entered swimmers count
  #
  def get_entered_swimmers_count
    @generals[:ent_swimmers_male_count] + @generals[:ent_swimmers_female_count]
  end

  # Sum male and female entries count
  #
  def get_entries_count
    @generals[:entries_male_count] + @generals[:entries_female_count]
  end
  # ---------------------------------------------------------------------------

  # Sum male and female swimmers count
  #
  def get_swimmers_count
    @generals[:swimmers_male_count] + @generals[:swimmers_female_count]
  end

  # Sum male and female results count
  #
  def get_results_count
    @generals[:results_male_count] + @generals[:results_female_count]
  end

  # Sum male and female disqualified count
  #
  def get_disqualifieds_count
    @generals[:dsqs_male_count] + @generals[:dsqs_female_count]
  end
  # ---------------------------------------------------------------------------

  # Ceates a new team element
  #
  def new_team(team)
    TeamMeetingStatDAO.new(team)
  end
  # ---------------------------------------------------------------------------

  # Ceates a new category element
  #
  def new_category(category_type)
    CategoryMeetingStatDAO.new(category_type)
  end
  # ---------------------------------------------------------------------------

  # Ceates a new event element
  #
  def new_event(event_type)
    EventMeetingStatDAO.new(event_type)
  end
  # ---------------------------------------------------------------------------

  # General property setter
  #
  def set_general(stat, value)
    @generals[stat.to_sym] = value if @generals.key?(stat.to_sym)
  end

  # General property getter
  # Note that get operation will run even with the only property name
  #
  def get_general(stat)
    @generals[stat.to_sym] if @generals.key?(stat.to_sym)
  end

  # Get team stats
  # Returns the team stats if any
  #
  def get_team_stats(team); end

  private

  def prepare_generals
    generals = {}

    # Entry-based
    generals[:ent_teams_count]           = 0
    generals[:ent_swimmers_male_count]   = 0
    generals[:ent_swimmers_female_count] = 0
    generals[:entries_male_count]        = 0
    generals[:entries_female_count]      = 0

    # Result-based
    generals[:teams_count]            = 0
    generals[:swimmers_male_count]    = 0
    generals[:swimmers_female_count]  = 0
    generals[:results_male_count]     = 0
    generals[:results_female_count]   = 0
    generals[:results_relay_count]    = 0
    generals[:dsqs_male_count]        = 0
    generals[:dsqs_female_count]      = 0
    generals[:dsqs_relay_count]       = 0
    generals[:oldest_male_swimmers]   = []
    generals[:oldest_female_swimmers] = []

    # Score-based
    generals[:average_male_score]      = 0
    generals[:average_female_score]    = 0
    generals[:average_relay_score]     = 0
    generals[:average_total_score]     = 0
    generals[:over_1000_count]         = 0
    generals[:over_950_count]          = 0
    generals[:over_900_count]          = 0
    generals[:best_std_male_scores]    = []
    generals[:best_std_female_scores]  = []
    generals[:worst_std_male_scores]   = []
    generals[:worst_std_female_scores] = []

    generals
  end

  # Override standard one using hash elements keys as methods
  #
  def method_missing(method, *args)
    key_name = method.to_s

    # Remove get for requests
    key_name.slice!(0..3) if key_name.start_with?('get_')

    @generals.key?(key_name.to_sym) ? @generals[key_name.to_sym] : BasicObject.send(:method_missing, method, *args)
  end
  # ---------------------------------------------------------------------------

end
