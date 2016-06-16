require 'spec_helper'


describe UserTrainingRow, :type => :model do
  context "[a well formed instance]" do
    subject { create(:user_training_row) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end


    context "[implemented methods]" do
      it_behaves_like( "(the existance of a class method)",
        [
          :compute_total_seconds
        ]
      )
      it_behaves_like( "(the existance of a method returning numeric values)",
        [ 
          :full_row_distance,
          :compute_distance,
          :full_row_seconds,
          :compute_total_seconds
        ]
      )
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "self.compute_total_seconds()" do
    it "returns 0 or a positive number" do
      training_rows = Training.find_by_id( ((rand * 10) % Training.count).to_i + 1 ).training_rows
      expect( subject.class.compute_total_seconds( training_rows ) ).to be >= 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  [ 
    :full_row_distance,
    :compute_distance,
    :full_row_seconds,
    :compute_total_seconds
  ].each do |method_name|
    describe "##{method_name}" do
      it "returns 0 or a positive number" do
        expect( subject.send(method_name) ).to be >= 0
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
