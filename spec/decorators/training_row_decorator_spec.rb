require 'spec_helper'


shared_examples_for "(TrainingRowDecorator usable for both TrainingRow & UserTrainingRow)" do
  it "has a not nil source row" do                  # (we check for nil to make sure the seed exists in the DB)
    expect( @fixture ).not_to be_nil
  end
  it "has a valid source row" do
    expect( @fixture ).to be_valid
  end

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :get_full_name,
# TODO REMOVE THIS:
        :to_array
      ]
    )
    it_behaves_like( "(the existance of a method returning strings)",
      [
        :get_formatted_pause,
        :get_formatted_start_and_rest,
        :get_formatted_part_order,
        :get_formatted_total_seconds,
        :get_formatted_distance,
        :get_row_description,

        :get_training_group_text,
        :get_formatted_group_pause,
        :get_formatted_group_start_and_rest,
        :get_training_step_type_short,
        :get_exercise_full,
        :get_arm_aux_type_name,
        :get_kick_aux_type_name,
        :get_body_aux_type_name,
        :get_breath_aux_type_name
      ]
    )
  end
end
#-- ---------------------------------------------------------------------------
#++


describe TrainingRowDecorator, type: :model do

  context "when used with TrainingRow" do
    before :each do
      @fixture = TrainingRow.find_by_id( ((rand * 100) % TrainingRow.count).to_i + 1 )
      @decorated_instance = TrainingRowDecorator.decorate( @fixture )
    end
    subject { @decorated_instance }

    it_behaves_like "(TrainingRowDecorator usable for both TrainingRow & UserTrainingRow)"
  end


  context "when used with UserTrainingRow" do
    before :each do
      @fixture = create( :user_training_row )
      @decorated_instance = TrainingRowDecorator.decorate( @fixture )
    end
    subject { @decorated_instance }

    it_behaves_like "(TrainingRowDecorator usable for both TrainingRow & UserTrainingRow)"
  end
end
#-- ---------------------------------------------------------------------------
#++
