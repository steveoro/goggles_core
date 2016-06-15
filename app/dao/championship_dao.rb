# encoding: utf-8

=begin

= ChampionshipDAO

  - Goggles framework vers.:  4.00.546
  - author: Leega

 DAO class containing the structure for chapionship ranking rendering.

=end
class ChampionshipDAO
  
  class TeamScoreDAO
    # These must be initialized on creation:
    attr_reader :team

    # These can be edited later on:
    attr_accessor :total_points, :meetings
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance.
    #
    def initialize( team )
      @team          = team
      @meetings      = []
      @total_points  = 0   # Automatically computed on meeting add
    end
    #-- -------------------------------------------------------------------------
    #++
    
    # Add a meeting to the meetings collection
    def add_meeting(season_meeting_team_score, columns)
      @meetings << season_meeting_team_score
      if season_meeting_team_score
        columns.each do |column|
          @total_points += season_meeting_team_score[column]
        end
      end
    end
  end

  # These must be initialized on creation:
  attr_reader :columns, :meetings, :team_scores
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance.
  #
  # Needs to  be sure team_scores is an instance of TeamScoreDAO
  # to perform correcto sorting
  #
  def initialize( columns, meetings, team_scores )
    unless team_scores.kind_of?( Array )
      raise ArgumentError.new("Championship DAO must be an array of TeamScoreDAO element")
    end
    team_scores.each do |team_score|
      if not team_score.instance_of?( ChampionshipDAO::TeamScoreDAO )
        raise ArgumentError.new("Championship DAO must contain a TeamScoreDAO element")
      end
    end
    @columns     = columns
    @meetings    = meetings
    @team_scores = team_scores.sort{ |p,n| n.total_points <=> p.total_points }
  end
  #-- -------------------------------------------------------------------------
  #++
end
