require 'spec_helper'


describe Training, :type => :model do
  context "[a well formed instance]" do
    subject { Training.find_by_id( ((rand * 10) % Training.count).to_i + 1 ) }

    it "is a not nil" do                            # (we check for nil to make sure the seed exists in the DB)
      expect( subject ).not_to be_nil
    end
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
end
