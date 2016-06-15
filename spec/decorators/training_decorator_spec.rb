require 'spec_helper'


shared_examples_for "(TrainingDecorator usable for both Training & UserTraining)" do
  it "has a not nil source row" do                  # (we check for nil to make sure the seed exists in the DB)
    expect( @fixture ).not_to be_nil
  end
  it "has a valid source row" do
    expect( @fixture ).to be_valid
  end

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method returning strings)",
      [
        :get_swimmer_level_type
      ]
    )
    it_behaves_like( "(the existance of a method returning non-empty strings)",
      [
        :get_suggested_swimmer_level_type
      ]
    )
    it_behaves_like( "(the existance of a method)",
      [
        :drop_down_attrs,
        :build_group_list_hash
      ]
    )
  end

  describe "#drop_down_attrs" do
    it "returns an Hash" do
      expect( subject.drop_down_attrs() ).to be_an_instance_of( Hash )
    end
    it "has the expected keys" do
      expect( subject.drop_down_attrs().keys ).to include(
        :label, :value, :tot_distance, :tot_secs, :user_name,
        :swimmer_level_type_description, :swimmer_level_type_alternate
      )
    end
  end

  describe "#build_group_list_hash" do
    it "returns an Hash" do
      expect( subject.build_group_list_hash() ).to be_an_instance_of( Hash )
    end

    context "when used on a Training with grouped details," do
      let( :fixture ) { create( :training_with_grouped_rows ) }
      let( :group_hash ) { TrainingDecorator.decorate( fixture ).build_group_list_hash() }

      it "has the expected keys" do
        expect( group_hash.values ).to all( be_an_instance_of( Hash ) )
        group_hash.values.each do |value_hash|
          expect( value_hash.keys ).to include( :id, :times, :start_and_rest, :pause, :training_step_code, :datarows, :tot_group_timing )
        end
      end
      it "has the :datarows member Array" do
        group_hash.values.each do |value_hash|
          expect( value_hash[:datarows] ).to be_an_instance_of( Array )
        end
      end
      it "has a non empty list of :datarows" do
        group_hash.values.each do |value_hash|
          expect( value_hash[:datarows].size ).to be > 0
        end
      end
    end
  end
end
#-- ---------------------------------------------------------------------------
#++


describe TrainingDecorator, type: :model do

  context "when used with Training" do
    before :each do
      @fixture = Training.find_by_id( ((rand * 10) % Training.count).to_i + 1 )
      @decorated_instance = TrainingDecorator.decorate( @fixture )
    end
    subject { @decorated_instance }

    it_behaves_like "(TrainingDecorator usable for both Training & UserTraining)"
  end


  context "when used with UserTraining" do
    before :each do
      @fixture = create( :user_training_with_rows )
      @decorated_instance = TrainingDecorator.decorate( @fixture )
    end
    subject { @decorated_instance }

    it_behaves_like "(TrainingDecorator usable for both Training & UserTraining)"
  end
end
#-- ---------------------------------------------------------------------------
#++
