require 'spec_helper'


describe ExerciseRowDecorator, type: :model do
  before :each do
    rnd_id = ((rand * 500) % ExerciseRow.count).to_i + 1
    @random_seed_row = ExerciseRow.find_by_id( rnd_id )
    @decorated_instance = ExerciseRowDecorator.decorate( @random_seed_row )
  end

  subject { @decorated_instance }

  it "has a not nil source row" do
    expect( @random_seed_row ).not_to be_nil
  end
  it "has a valid source row" do
    expect( @random_seed_row ).to be_valid
  end


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method returning non-empty strings)",
      [
        :get_full_name
      ]
    )
    it_behaves_like( "(the existance of a method returning strings)",
      [
        :get_formatted_pause,
        :get_formatted_start_and_rest,
        :get_base_movement_full,
        :get_base_movement_short,
        :get_execution_note_type_name,
        :get_training_mode_type_name
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
