# encoding: utf-8

require 'rails_helper'
require 'sql_converter'


class DummySqlConverterIncludee
  include SqlConverter
end


describe SqlConverter, type: :strategy do

  subject do
    DummySqlConverterIncludee.new
  end

  let(:record)   { create( :training ) }

  context "as an included module," do
    it_behaves_like( "SqlConverter [param: let(:record)]" )
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#begin_capture_sql_delete" do
    it "logs the DELETE statement into #captured_sql_text" do
      # Create a deletable fixture, with some children rows:
      meeting = FactoryGirl.create( :meeting_with_sessions )

      subject.begin_capture_sql_delete( meeting )   # BEGIN Capture
      expect( meeting.class.connection.captured_sql_delete_text ).to be nil
      # Perform the destroy:
      expect( meeting.destroy ).to be_a( Meeting )
      expect( meeting.destroyed? ).to be true
      # Test the dedicated member log:
      expect( meeting.class.connection.captured_sql_delete_text ).to include("DELETE")
      expect( meeting.class.connection.captured_sql_delete_text ).to include( meeting.class.table_name )
      expect( meeting.class.connection.captured_sql_delete_text ).to include( meeting.id.to_s )
# DEBUG
#      puts "\r\n---- CAPTURED SQL ----"
#      puts meeting.class.connection.captured_sql_delete_text
#      puts "----------------------"
      subject.end_capture_sql_delete( meeting )     # END Capture
    end
  end

  # FIXME CANNOT EXECUTE MORE THAN 1 TEST ON THIS Monkey-patching method, since
  # tests are parallelized and may rise a Stack-level-too-deep error!

  describe "#end_capture_sql_delete" do
    xit "prevents the logging of the DELETE statement" do
      # Create a deletable fixture, with some children rows:
      meeting = FactoryGirl.create( :meeting_with_sessions )

      subject.begin_capture_sql_delete( meeting )   # BEGIN Capture
      expect( meeting.class.connection.captured_sql_delete_text ).to be nil
      subject.end_capture_sql_delete( meeting )     # END Capture

      # Perform the destroy:
      expect( meeting.destroy ).to be_a( Meeting )
      # Test the dedicated member log:
      expect( meeting.class.connection.captured_sql_delete_text ).to eq("")
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
