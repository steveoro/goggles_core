# frozen_string_literal: true

class AddFieldsToFinCalendar < ActiveRecord::Migration[5.0]

  def change
    change_table :fin_calendars, bulk: true do |t|
      t.column :calendar_year, :string, limit: 4, default: nil, null: true
      t.column :calendar_month, :string, limit: 20, default: nil, null: true

      t.column :results_link, :string, default: nil, null: true
      t.column :startlist_link, :string, default: nil, null: true
      t.column :manifest_link, :string, default: nil, null: true

      # Full manifest (typically 25..100K unstripped)
      t.column :manifest, :text, default: nil, null: true

      # These are extracted from the manifest (especially when it is too big) and
      # used as an offline buffer during the parsing phase for the calendar:
      t.column :name_import_text,         :text, default: nil, null: true
      t.column :organization_import_text, :text, default: nil, null: true
      t.column :place_import_text,        :text, default: nil, null: true
      t.column :dates_import_text,        :text, default: nil, null: true
      t.column :program_import_text,      :text, default: nil, null: true

      t.rename_column(:fin_invitation_code, :fin_manifest_code)
      t.rename_column(:fin_result_code,     :fin_results_code)

      # This may be nil until Meeting is created or recognized (absolutely no foreign key)
      t.reference :meeting
    end
  end

end
