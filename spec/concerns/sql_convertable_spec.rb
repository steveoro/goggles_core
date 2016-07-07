require 'spec_helper'

require 'goggle_cup'


# Dummy class holder for the fields used by the module
# Doesn't metter the model class used as base
class DummySqlConvertableIncludee < GoggleCup
  include SqlConvertable
end
# -----------------------------------------------------------------------------


describe DummySqlConvertableIncludee do
  subject = DummySqlConvertableIncludee.new

  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context "by including this concern" do
    it_behaves_like( "(the existance of a method)",
      [
        :sql_diff_text_log,
        :reset_sql_diff_text_log,
        :create_sql_diff_header,
        :create_sql_diff_footer,
        :add_sql_diff_comment
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#reset_sql_diff_text_log," do
    it "resets @sql_diff_text_log" do
      subject.reset_sql_diff_text_log
      expect( subject.sql_diff_text_log.size ).to eq( 0 )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#create_sql_diff_header," do
    context "without parameters" do
      it "adds begin script comment to @sql_diff_text_log" do
        subject.reset_sql_diff_text_log
        subject.create_sql_diff_header
        expect( subject.sql_diff_text_log.include?( 'Begin script' ) ).to be true
      end
    end

    context "with parameters" do
      it "adds also a line containing given text to @sql_diff_text_log" do
        fix_text = FFaker::Lorem.sentence
        subject.reset_sql_diff_text_log
        subject.create_sql_diff_header( fix_text )
        expect( subject.sql_diff_text_log.include?( 'Begin script' ) ).to be true
        expect( subject.sql_diff_text_log.include?( fix_text ) ).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#create_sql_diff_footer," do
    context "without parameters" do
      it "adds script ended comment to @sql_diff_text_log" do
        subject.reset_sql_diff_text_log
        subject.create_sql_diff_footer
        expect( subject.sql_diff_text_log.include?( 'Script ended' ) ).to be true
      end
    end

    context "with parameters" do
      it "adds also a line containing given text to @sql_diff_text_log" do
        fix_text = FFaker::Lorem.sentence
        subject.reset_sql_diff_text_log
        subject.create_sql_diff_footer( fix_text )
        expect( subject.sql_diff_text_log.include?( 'Script ended' ) ).to be true
        expect( subject.sql_diff_text_log.include?( fix_text ) ).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#add_sql_diff_comment," do
    context "without parameters" do
      it "adds at least 1 comment line to @sql_diff_text_log" do
        subject.reset_sql_diff_text_log
        subject.add_sql_diff_comment
        expect( subject.sql_diff_text_log.size ).to be >= 1
      end
    end

    context "with parameters" do
      it "adds a line containing given text to @sql_diff_text_log" do
        fix_text = FFaker::Lorem.sentence
        subject.reset_sql_diff_text_log
        subject.add_sql_diff_comment( fix_text )
        expect( subject.sql_diff_text_log.include?( fix_text ) ).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
