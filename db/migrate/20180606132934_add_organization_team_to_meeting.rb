class AddOrganizationTeamToMeeting < ActiveRecord::Migration[5.1]
  def change
    # This may be nil until Meeting is created or recognized (absolutely no foreign key)
    add_reference( :meetings, :organization_team, index: true, foreign_key: false )

    # Crawler-only flag:
    add_column( :meetings, :do_not_update, :boolean, default: false, null: false, index: true )
    add_column( :fin_calendars, :do_not_update, :boolean, default: false, null: false, index: true )
  end
end
