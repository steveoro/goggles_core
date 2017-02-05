class CreateSwimmerSeasonScores < ActiveRecord::Migration[5.0]
  def change
    create_table :swimmer_season_scores do |t|
      t.integer :lock_version, :default => 0

      t.decimal :score, precision: 10, scale: 2
      t.references :badge, foreign_key: true
      t.references :meeting_individual_result, foreign_key: true
      t.references :event_type, foreign_key: true

      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :swimmer_season_scores, [:badge_id, :event_type_id], name: 'swimmer_season_scores_badge_event'
    add_index :swimmer_season_scores, [:badge_id, :score], name: 'swimmer_season_scores_badge_score'
  end
end
