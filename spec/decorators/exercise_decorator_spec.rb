require 'spec_helper'


describe ExerciseDecorator, type: :model do
  before :each do
    rnd_id = ((rand * 500) % Exercise.count).to_i + 1
    @random_seed_row = Exercise.find_by_id( rnd_id )
    @decorated_instance = ExerciseDecorator.decorate( @random_seed_row )
  end

  subject { @decorated_instance }

  it "has a not nil source row" do
    expect( @random_seed_row ).not_to be_nil
  end
  it "has a valid source row" do
    expect( @random_seed_row ).to be_valid
  end


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method returning a non-empty Hash)",
      [
        :drop_down_attrs
      ]
    )
    it_behaves_like( "(the existance of a method returning non-empty strings)",
      [
        :get_full_name
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#drop_down_attrs" do
    it "returns an Hash with the expected keys" do
      result = subject.drop_down_attrs()
      expect( result.keys ).to include(
        :label, :value, :tot_distance, :tot_secs, :is_arm_aux_allowed,
        :is_kick_aux_allowed, :is_body_aux_allowed, :is_breath_aux_allowed
      )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
