# frozen_string_literal: true

require 'active_support'

#
# = MeetingAccountable
#
#   - version:  4.00.325.20140620
#   - author:   Steve A.
#
#   Concern that adds methods to count meeting results and entries for the
#   current (includee) instance.
#
#   Assumes the includee is related to a Meeting (either directly or indirectly)
#   and has ActiveRecord::relation helpers included for:
#
#     #meeting_individual_results
#     #meeting_entries
#
module MeetingAccountable
  extend ActiveSupport::Concern

  # Counts the results for the meeting associated to the current instance,
  # invoking the filtering scope block when it is given.
  #
  # === Sample usage:
  #
  # Using a pre-defined scope:
  #
  #  > p = MeetingProgram.first
  #  > p.count_results( &:is_valid )
  #
  # Or with scope blocks:
  #
  #  > p.count_results() { |rel| rel.where(team_id: 1) }
  #
  def count_results(&scope_block)
    return 0 unless meeting_individual_results

    if scope_block
      scope_block.call(meeting_individual_results).count
    else
      meeting_individual_results.count
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Counts the entries for the meeting associated to the current instance,
  # invoking the filtering scope block when it is given.
  #
  # === Sample usage:
  #
  # Using a pre-defined scope:
  #
  #  > p = MeetingProgram.first
  #  > p.count_entries( &:is_female )
  #
  # Or with scope blocks:
  #
  #  > p.count_entries() { |rel| rel.where(team_id: 1) }
  #
  def count_entries(&scope_block)
    return 0 unless meeting_entries

    if scope_block
      scope_block.call(meeting_entries).count
    else
      meeting_entries.count
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
