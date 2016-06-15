# encoding: utf-8
require 'spec_helper'

require 'entity_row_dup_collector'


describe EntityRowDupCollector, type: :strategy do

  subject { EntityRowDupCollector.new( CategoryType ) }

  it_behaves_like( "(the existance of a method)", [
    :duplicate_rows, :non_duplicates_rows,
    :source_rows, :dest_rows,
    :process
  ] )
  #-- -------------------------------------------------------------------------
  #++


  describe "#process" do
    context "when splitting a random set with both dups & non-dups" do
      before(:all) do
        @season_1 = SeasonFactoryTools.get_season_with_full_categories()
        @season_2 = SeasonFactoryTools.get_season_with_full_categories()
        # (Keep in mind that the seasons may be the same)
        @subject = EntityRowDupCollector.new( CategoryType )
        lambda_filter = ->(id) { where( season_id: id ) }
                                                  # Launch the process:
        @subject.process( @season_1.id, lambda_filter, @season_2.id, lambda_filter ) do |src_row, dest_row|
          (src_row.code == dest_row.code)         # equality check block
        end
      end

      it "finds some dup rows" do
        expect( @subject.duplicate_rows.count ).to be > 0
      end
      it "has some source rows" do
        expect( @subject.source_rows.count ).to be > 0
      end
      it "has some destination rows" do
        expect( @subject.dest_rows.count ).to be > 0
      end
    end


    context "when splitting a set with a precise number of dups & non-dups" do
      before(:all) do
=begin
        As of 2015-01-29, the fixture data contains:

        CategoryType.where( age_end: 24).where('season_id < 145').count
        => 40
        CategoryType.where( age_end: 24).where('season_id < 145').where(code: 'M20').count
        => 13
        CategoryType.where( age_end: 24).where('season_id < 145').where(code: 'U25').count
        => 27
=end
        @season_1 = SeasonFactoryTools.get_season_with_full_categories()
        @season_2 = SeasonFactoryTools.get_season_with_full_categories()
        # (Keep in mind that the seasons may be the same)
        @subject = EntityRowDupCollector.new( CategoryType )
        @subject.process(
          # param.  lambda filter:
          24,       ->(age) { where( age_end: age).where('season_id < 145') }, # source (min 40, 13 dups)
          24,       ->(age) { where( age_end: age).where('season_id < 145').where(code: 'M20') }, # dest. (min 13)
        ) do |src_row, dest_row|
          (src_row.code == dest_row.code)         # equality check block
        end
      end

      it "finds at least 13 dup rows" do
        expect( @subject.duplicate_rows.count ).to be >= 13
      end
      it "finds at least 27 non-dup rows" do
        expect( @subject.non_duplicates_rows.count ).to be >= 27
      end
      it "has at least 40 source rows" do
        expect( @subject.source_rows.count ).to be >= 40
      end
      it "has at least 13 destination rows" do
        expect( @subject.dest_rows.count ).to be >= 13
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

