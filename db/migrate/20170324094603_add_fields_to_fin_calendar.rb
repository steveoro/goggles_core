class AddFieldsToFinCalendar < ActiveRecord::Migration[5.0]
  def change
    add_column :fin_calendars, :calendar_year, :string, limit: 4, default: nil, null: true
    add_column :fin_calendars, :calendar_month, :string, limit: 20, default: nil, null: true

    add_column :fin_calendars, :results_link, :string, default: nil, null: true
    add_column :fin_calendars, :startlist_link, :string, default: nil, null: true
    add_column :fin_calendars, :manifest_link, :string, default: nil, null: true

    # Full manifest (typically 25..100K unstripped)
    add_column :fin_calendars, :manifest, :text, default: nil, null: true

    # These are extracted from the manifest (especially when it is too big) and
    # used as an offline buffer during the parsing phase for the calendar:
    add_column :fin_calendars, :name_import_text,         :text, default: nil, null: true
    add_column :fin_calendars, :organization_import_text, :text, default: nil, null: true
    add_column :fin_calendars, :place_import_text,        :text, default: nil, null: true
    add_column :fin_calendars, :dates_import_text,        :text, default: nil, null: true
    add_column :fin_calendars, :program_import_text,      :text, default: nil, null: true

    rename_column( :fin_calendars, :fin_invitation_code, :fin_manifest_code )
    rename_column( :fin_calendars, :fin_result_code,     :fin_results_code )

    # This may be nil until Meeting is created or recognized (absolutely no foreign key)
    add_reference :fin_calendars, :meeting
  end
end
