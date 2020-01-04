# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarBaseBuilder, type: :strategy do
  context 'with valid parameters,' do
    subject { FinCalendarBaseBuilder.new( User.find(1) ) }

    it_behaves_like( '(the existance of a method)', [
                      :report, :find_or_create!,
                      :has_updated, :has_created, :has_errors, :has_changes?
                    ] )
    #-- -----------------------------------------------------------------------
    #++

    describe '#report' do
      context 'right from the start,' do
        it 'does not change the output' do
          output = []
          expect { subject.report( output, :<< ) }
            .not_to change(output, :count)
        end
        it 'is an empty text' do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to eq('')
        end
      end

      context 'after a #find_or_create! call,' do
        it 'does not change the output' do
          output = []
          subject.find_or_create!
          expect { subject.report( output, :<< ) }
            .not_to change(output, :count)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with invalid parameters,' do
    it 'raises an ArgumentError' do
      expect { FinCalendarMeetingBuilder.new }.to raise_error( ArgumentError )
      expect { FinCalendarMeetingBuilder.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarMeetingBuilder.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
