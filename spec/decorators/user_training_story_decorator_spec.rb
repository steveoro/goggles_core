require 'spec_helper'


describe UserTrainingStoryDecorator, type: :model do
  before :each do
    @fixture = create( :user_training_story )
    @decorated_instance = UserTrainingStoryDecorator.decorate( @fixture )
  end

  subject { @decorated_instance }

  it "has a not nil source row" do
    expect( @fixture ).not_to be_nil
  end
  it "has a valid source row" do
    expect( @fixture ).to be_valid
  end


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method returning strings)",
      [
        :get_user_training_name,
        :get_swimmer_level_type,
        :get_user_swimmer_level_type
      ]
    )
    it_behaves_like( "(the existance of a method returning numeric values)",
      [
        :get_user_training_total_distance,
        :get_user_training_esteemed_total_seconds
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
