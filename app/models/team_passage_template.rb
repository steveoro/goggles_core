class TeamPassageTemplate < ApplicationRecord
  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  # validates_associated :user                       # (Do not enable this for User)

  belongs_to :team
  belongs_to :event_type
  belongs_to :pool_type
  belongs_to :passage_type

  validates_associated :team
  validates_associated :event_type
  validates_associated :pool_type
  validates_associated :passage_type

  has_one  :stroke_type,    through: :event_type

  scope :sort_by_length,     -> { joins( :passage_type ).includes( :passage_type ).order('passage_types.length_in_meters') }

  scope :for_team,           ->(team)       { where(['team_id = ?', team.id]) }
  scope :for_event_type,     ->(event_type) { where(['event_type_id = ?', event_type.id]) }
  scope :for_pool_type,      ->(pool_type)  { where(['pool_type_id = ?', pool_type.id]) }

  # Returns an array of PassageType rows enlisting the default sequence of
  # passage types for the specified length_in_meters.
  #
  def self.get_default_passage_types_for( total_length_in_meters, pool_length = 50 )
    PassageType.where( ["length_in_meters <= ?", total_length_in_meters] )
      .order( :length_in_meters )
      .to_a
      .delete_if do |row|
        (total_length_in_meters > 100) && (row.length_in_meters % 50 != 0) || ( row.length_in_meters % pool_length != 0 )
      end
  end

  # Returns an array of PassageType rows enlisting the default sequence of
  # passage types for the specified team passage template
  #
  def self.get_template_passage_types_for( team, event_type, pool_type )
    team.team_passage_templates.for_event_type( event_type ).for_pool_type( pool_type ).count > 0 ?
      team.team_passage_templates.for_event_type( event_type ).for_pool_type( pool_type ).includes( :passage_type ).sort_by_length.map{ |t| t.passage_type } :
      []
  end
end
