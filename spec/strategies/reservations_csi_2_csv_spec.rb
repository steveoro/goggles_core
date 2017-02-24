require 'rails_helper'
require 'fileutils'
require 'reservations_csi_2_csv'



describe ReservationsCsi2Csv, type: :strategy do
  let(:meeting_not_csi) do
    Meeting.includes(:season_type).joins(:season_type)
      .where(['season_types.code != ?', 'MASCSI'])
      .limit(100).sort{0.5 - rand}
      .first
  end

  let(:meeting_csi_w_o_res) do
    Meeting.includes(:season_type).joins(:season_type)
      .where(['season_types.code = ? AND meetings.id < 16000', 'MASCSI'])
      .limit(100).sort{0.5 - rand}
      .first
  end

  let(:meeting_csi_w_res) do
    Meeting.includes(:season_type, :meeting_reservations).joins(:season_type, :meeting_reservations)
      .where(['season_types.code = ?', 'MASCSI'])
      .limit(200).sort{0.5 - rand}
      .first
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with invalid constructor parameters," do
    it "raises an ArgumentError" do
      expect{ ReservationsCsi2Csv.new }.to raise_error( ArgumentError )
      expect{ ReservationsCsi2Csv.new('not a meeting') }.to raise_error( ArgumentError )
      # Not a CSI-season_type meeting:
      expect{ ReservationsCsi2Csv.new( meeting_not_csi ) }.to raise_error( ArgumentError )
    end
  end


  context "with valid constructor parameters," do
    # Any CSI-season_type meeting:
    subject{ ReservationsCsi2Csv.new( meeting_csi_w_res ) }

    it "is a ReservationsCsi2Csv instance" do
      expect( subject ).to be_a( ReservationsCsi2Csv )
    end

    it_behaves_like( "(the existance of a method)", [
      :csi_data_rows, :created_file_full_pathname,
      :collect, :save_to_file
    ] )

    it "presets #csi_data_rows to an empty array" do
      expect( subject.csi_data_rows ).to eq([])
    end
    it "presets #created_file_full_pathname to nil" do
      expect( subject.created_file_full_pathname ).to be nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "for a valid instance," do
    context "for a Meeting without any reservations" do
      subject do
        ReservationsCsi2Csv.new( meeting_csi_w_o_res )
      end

      describe "#collect()" do
        it "does not change the size of #csi_data_rows (from 0)" do
          expect( subject.csi_data_rows.size ).to eq(0)
          expect{ subject.collect }.not_to change{ subject.csi_data_rows }
        end
      end
      describe "#save_to_file()" do
        it "does not save the output file" do
          subject.collect
          expect( subject.save_to_file ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context "for a Meeting with some reservations" do
      subject do
        ReservationsCsi2Csv.new( meeting_csi_w_res )
      end

      describe "#collect()" do
        it "increases the size of #csi_data_rows" do
          expect( subject.csi_data_rows.size ).to eq(0)
          expect{ subject.collect }.to change{ subject.csi_data_rows }
        end
      end
      describe "#save_to_file()" do
        it "does not save the output file" do
          subject.collect
          created_filename = subject.save_to_file
          expect( created_filename).not_to be nil
          # Remove the useless created test output file:
          FileUtils.rm( created_filename )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
