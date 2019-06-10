# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'
require 'reservations_csi_2_csv_matrix'

describe ReservationsCsi2CsvMatrix, type: :strategy, tag: :reservation do
  let(:meeting_not_csi) do
    Meeting.includes(:season_type).joins(:season_type)
           .where(['season_types.code != ?', 'MASCSI'])
           .limit(100)
           .sample
  end

  let(:meeting_csi_w_o_res) do
    Meeting.includes(:season_type).joins(:season_type)
           .where(['season_types.code = ? AND meetings.id < 16000', 'MASCSI'])
           .limit(100)
           .sample
  end

  let(:meeting_csi_w_res) do
    meeting = Meeting.includes(:season_type, :meeting_event_reservations)
                     .joins(:season_type, :meeting_event_reservations)
                     .where(['(season_types.code = ?) AND (meeting_event_reservations.is_doing_this = ?)', 'MASCSI', true])
                     .limit(200)
                     .sample
    expect(meeting).to be_a(Meeting)
    expect(meeting.meeting_reservations.count).to be > 0
    expect(meeting.meeting_event_reservations.count).to be > 0
    meeting
  end

  let(:team_for_meeting_csi_w_res) do
    MeetingEventReservation.where(meeting_id: meeting_csi_w_res.id, is_doing_this: true)
                           .select(:team_id).distinct
                           .sample
                           .team
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.is_a_csi_meeting,' do
    it 'responds to self.is_a_csi_meeting' do
      expect(ReservationsCsi2CsvMatrix).to respond_to(:is_a_csi_meeting)
    end

    it 'returns false for a nil instance' do
      expect(ReservationsCsi2CsvMatrix.is_a_csi_meeting(nil)).to be false
    end
    it 'returns false for a non-Meeting instance' do
      expect(ReservationsCsi2CsvMatrix.is_a_csi_meeting('not a meeting!')).to be false
    end
    it 'returns false for a non-CSI Meeting instance' do
      expect(ReservationsCsi2CsvMatrix.is_a_csi_meeting(meeting_not_csi)).to be false
    end
    it 'returns true for a CSI Meeting instance w/o reservations' do
      expect(ReservationsCsi2CsvMatrix.is_a_csi_meeting(meeting_csi_w_o_res)).to be true
    end
    it 'returns true for a CSI Meeting instance w/ reservations' do
      expect(ReservationsCsi2CsvMatrix.is_a_csi_meeting(meeting_csi_w_res)).to be true
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with invalid constructor parameters,' do
    it 'raises an ArgumentError' do
      expect { ReservationsCsi2CsvMatrix.new }.to raise_error(ArgumentError)
      expect { ReservationsCsi2CsvMatrix.new('not a meeting') }.to raise_error(ArgumentError)
      # Not a CSI-season_type meeting:
      expect { ReservationsCsi2CsvMatrix.new(meeting_not_csi) }.to raise_error(ArgumentError)
    end
  end

  context 'with valid constructor parameters,' do
    # Any CSI-season_type meeting:
    subject { ReservationsCsi2CsvMatrix.new(meeting_csi_w_res) }

    it 'is a ReservationsCsi2CsvMatrix instance' do
      expect(subject).to be_a(ReservationsCsi2CsvMatrix)
    end

    it_behaves_like('(the existance of a method)', [:csi_data_rows, :created_file_full_pathname, :collect, :output_text, :save_to_file])

    it 'presets #csi_data_rows to an empty array' do
      expect(subject.csi_data_rows).to eq([])
    end
    it 'presets #created_file_full_pathname to nil' do
      expect(subject.created_file_full_pathname).to be nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'for a valid instance,' do
    context 'for a Meeting without any reservations' do
      subject do
        ReservationsCsi2CsvMatrix.new(meeting_csi_w_o_res)
      end

      describe '#collect()' do
        it 'does not change the size of #csi_data_rows (from 0)' do
          expect(subject.csi_data_rows.size).to eq(0)
          expect { subject.collect }.not_to change { subject.csi_data_rows }
        end
      end
      describe '#save_to_file()' do
        it 'does not save the output file' do
          subject.collect
          expect(subject.save_to_file).to be nil
        end
      end
      describe '#output_text()' do
        it 'returns nil' do
          subject.collect
          expect(subject.output_text).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'for a Meeting with some reservations,' do
      context 'without any team filtering,' do
        subject do
          ReservationsCsi2CsvMatrix.new(meeting_csi_w_res)
        end

        describe '#collect()' do
          it 'increases the size of #csi_data_rows' do
            expect(subject.csi_data_rows.size).to eq(0)
            expect { subject.collect }.to change { subject.csi_data_rows }
          end
        end
        describe '#save_to_file()' do
          it 'saves the output file' do
            subject.collect
            created_filename = subject.save_to_file
            expect(created_filename).not_to be nil
            # Remove the useless created test output file:
            FileUtils.rm(created_filename)
          end
        end

        describe '#output_text()' do
          before(:each) { subject.collect }
          it 'returns the collected text' do
            expect(subject.output_text).not_to be nil
            expect(subject.output_text.length).to be > 0
            # DEBUG
            #            puts "\r\n------8<--------[Output text]:"
            #            puts subject.output_text
            #            puts "------8<--------[output lines: #{ subject.output_text.split("\r\n").count }]"
          end
          it "is composed of lines having the same number of columns (separated by ';' and after the headers)" do
            lines_array = subject.output_text.split("\r\n").map { |line| line.split(';') }
            # DEBUG
            #            puts "\r\n------8<--------[lines_array]:"
            #            lines_array.each{|line_array| puts "Columns: #{ line_array.count } => #{ line_array.inspect }" }
            #            puts "------8<--------[lines_array count: #{ lines_array.count }]"
            # Each line must have the same count of elements as the first one:
            lines_array.each_with_index do |line, index|
              # Skip the pre-header with team & meeting info:
              expect(line.count).to eq(lines_array.last.count) if index > 10
            end
          end
        end
      end
      #-- ---------------------------------------------------------------------
      #++

      context "when filtering by one of the reservations' team," do
        subject do
          # Verify that the subject is well-formed:
          expect(meeting_csi_w_res.meeting_event_reservations.count).to be > 0
          expect(
            MeetingEventReservation.where(
              meeting_id: meeting_csi_w_res.id,
              team_id: team_for_meeting_csi_w_res.id,
              is_doing_this: true
            ).count
          ).to be > 0
          ReservationsCsi2CsvMatrix.new(meeting_csi_w_res, team_for_meeting_csi_w_res)
        end

        describe '#collect()' do
          it 'increases the size of #csi_data_rows of the tot. reservation rows for the specified team' do
            expect(subject.csi_data_rows.size).to eq(0)
            subject.collect
            # Get the total of possible output rows, that is the number of distinct
            # swimmers actually engaging in a least an event:
            total_swimmer_reservations = MeetingEventReservation.where(
              meeting_id: meeting_csi_w_res.id,
              team_id: team_for_meeting_csi_w_res.id,
              is_doing_this: true
            ).select(:swimmer_id)
                                                                .distinct.count

            expect(subject.csi_data_rows.size).to eq(total_swimmer_reservations)
          end
        end
        describe '#save_to_file()' do
          it 'saves the output file' do
            subject.collect
            created_filename = subject.save_to_file
            expect(created_filename).not_to be nil
            # Remove the useless created test output file:
            FileUtils.rm(created_filename)
          end
        end
      end
      #-- ---------------------------------------------------------------------
      #++
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
