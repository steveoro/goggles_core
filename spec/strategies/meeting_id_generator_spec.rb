# frozen_string_literal: true

require 'rails_helper'

describe MeetingIDGenerator, type: :strategy do
  it_behaves_like( '(the existance of a class method)', [
                    :get_free_id
                  ] )
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.get_free_id()' do
    context "for *ALL* 'MASFIN' seasons after 2010," do
      Season.where(season_type_id: 1).where("begin_date > '2010-09-01'").each do |season|
        it 'returns a positive number' do
          result = MeetingIDGenerator.get_free_id( season )
          expect( result ).to be_a(Integer)
          expect( result ).to be > 0
        end
      end
    end

    context "for *ALL* 'MASCSI' seasons after 2010," do
      Season.where(season_type_id: 2).where("begin_date > '2010-09-01'").each do |season|
        it 'returns a positive number' do
          result = MeetingIDGenerator.get_free_id( season, 10 )
          expect( result ).to be_a(Integer)
          expect( result ).to be > 0
        end
      end
    end

    context "for *ALL* 'MASUISP' seasons after 2010," do
      Season.where(season_type_id: 3).where("begin_date > '2010-09-01'").each do |season|
        it 'returns a positive number' do
          result = MeetingIDGenerator.get_free_id( season )
          expect( result ).to be_a(Integer)
          expect( result ).to be > 0
        end
      end
    end

    context "for *ALL* 'MASLEN' seasons after 2010," do
      Season.where(season_type_id: 7).where("begin_date > '2010-09-01'").each do |season|
        it 'returns a positive number' do
          result = MeetingIDGenerator.get_free_id( season )
          expect( result ).to be_a(Integer)
          expect( result ).to be > 0
        end
      end
    end

    context "for *ALL* 'MASFINA' seasons after 2010," do
      Season.where(season_type_id: 8).where("begin_date > '2010-09-01'").each do |season|
        it 'returns a positive number' do
          result = MeetingIDGenerator.get_free_id( season )
          expect( result ).to be_a(Integer)
          expect( result ).to be > 0
        end
      end
    end
  end
  #-- -----------------------------------------------------------------------
  #++
end
