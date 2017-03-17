require 'rails_helper'


shared_examples_for "SqlConvertable [subject: includee]" do

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
        :add_sql_diff_comment,
        :save_diff_file
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

  describe "#save_diff_file," do
    context "with parameters" do
      it "saves the specified file with a START TRANSACTION and a COMMIT" do
        filename = '/tmp/spect_test_diff.sql'
        subject.save_diff_file( filename )
        expect( File.exists?( filename ) ).to be true
        f = File.new( filename )
        text = f.read
        expect( text ).to include('START TRANSACTION;')
        expect( text ).to include('COMMIT;')
        File.delete( filename )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
