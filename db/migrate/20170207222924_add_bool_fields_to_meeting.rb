class AddBoolFieldsToMeeting < ActiveRecord::Migration[5.0]
  def change
    add_column :meetings, :is_tweeted, :boolean, :default => false
    add_column :meetings, :is_fb_posted, :boolean, :default => false
    add_column :meetings, :is_cancelled, :boolean, :default => false
    add_column :meetings, :is_pb_scanned, :boolean, :default => false
  end
end
