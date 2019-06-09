# frozen_string_literal: true

require 'active_support'

#
# = DataImportable
#
#   - version:  6.078
#   - author:   Steve A.
#
#   Concern that adds relation to a data_import_session plus some other shared
#   helper methods.
#
module DataImportable
  extend ActiveSupport::Concern

  included do
    belongs_to            :data_import_session
    validates_associated  :data_import_session
  end

  # Computes a verbose or formal description for the row data "conflicting"
  # with the current import data row.
  def get_verbose_conflicting_row
    if conflicting_id.to_i > 0
      conflicting_row = self.class.find(conflicting_id)
      if conflicting_row
        verbose_desc = (conflicting_row.respond_to?(:get_verbose_name) ? conflicting_row.get_verbose_name : conflicting_row.inspect)
        "(ID:#{conflicting_id}) #{verbose_desc}"
      else
        "(ID:#{conflicting_id}) <#{I18n.t('activerecord.errors.unable_to_retrieve_row_data')}>"
      end
    else
      ''
    end
  end
  # ---------------------------------------------------------------------------
end
