require 'active_support'

=begin
  
= DataImportable

  - version:  4.00.219.20140413
  - author:   Steve A.

  Concern that adds relation to a data_import_session plus some other shared
  helper methods.

=end
module DataImportable
  extend ActiveSupport::Concern

  included do
    belongs_to            :data_import_session
    validates_associated  :data_import_session
  end


  # Computes a verbose or formal description for the row data "conflicting"
  # with the current import data row.
  def get_verbose_conflicting_row
    if ( self.conflicting_id.to_i > 0 )
      begin
        conflicting_row = self.class.find( conflicting_id )
        verbose_desc = ( conflicting_row.respond_to?(:get_verbose_name) ? conflicting_row.get_verbose_name : conflicting_row.inspect )
        "(ID:#{conflicting_id}) #{verbose_desc}"
      rescue
        "(ID:#{conflicting_id}) <#{I18n.t(:unable_to_retrieve_row_data, scope: [:activerecord, :errors] )}>"
      end
    else
      ''
    end
  end
  # ---------------------------------------------------------------------------
end
