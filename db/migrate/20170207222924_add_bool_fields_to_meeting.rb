# frozen_string_literal: true

class AddBoolFieldsToMeeting < ActiveRecord::Migration[5.0]

  def change
    change_table :meetings, bulk: true do |t|
      t.column :is_tweeted, :boolean, default: false
      t.column :is_fb_posted, :boolean, default: false
      t.column :is_cancelled, :boolean, default: false
      t.column :is_pb_scanned, :boolean, default: false
    end
  end

end
