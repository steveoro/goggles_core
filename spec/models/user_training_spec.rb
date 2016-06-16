require 'spec_helper'


describe UserTraining, :type => :model do
  context "[a well formed instance]" do
    subject { create(:user_training_with_rows) }

    it_behaves_like "TrainingSharable"

    it "is a valid istance" do
      expect( subject ).to be_valid
    end


    context "[implemented methods]" do
      it_behaves_like( "(the existance of a method returning strings)",
        [
          :get_user_name
        ]
      )
      it_behaves_like( "(the existance of a method returning non-empty strings)",
        [
          :get_full_name, 
          :get_verbose_name
        ]
      )
      it_behaves_like( "(the existance of a method returning numeric values)",
        [ 
          :total_distance,
          :compute_total_distance,
          :esteemed_total_seconds,
          :compute_total_seconds
        ]
      )
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  [ 
    :total_distance,
    :compute_total_distance,
    :esteemed_total_seconds,
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

  [ 
    :compute_step_distance
  ].each do |method_name|
    before :each do
      @fix_step_code = TrainingStepType.all[ ((rand * 100) % TrainingStepType.count).to_i ] # Assumes from seed 
    end

    describe "##{method_name}" do
      it "returns 0 or a positive number" do
        expect( subject.send(method_name, @fix_step_code) ).to be >= 0
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
