# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'SwimmerRelatable' do
  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context 'by including this concern' do
    it_behaves_like('(the existance of a method)',
                    [:swimmer, :get_swimmer_name, :get_year_of_birth, :get_swimmer_age, :get_swimmer_current_category])
  end
  #-- -------------------------------------------------------------------------
  #++

  # Should retrieve the complete athlete name (last name + ' ' + first_name)
  #
  describe '#get_swimmer_name' do
    # Since we are dealing with generic instances (not necessarily with
    # valid ones) we cannot say nothing more than this:
    it 'returns always a non-nil string' do
      expect(subject.get_swimmer_name).not_to be_nil
    end

    # THESE examples have more to do with validation than actual method basic functionality.
    # TODO make a dedicated method to validate/check the result (#is_swimmer_name_valid?)
    # TODO this will be its spec:
    #    it "returns always a non-empty string" do
    #      expect( subject.get_swimmer_name ).not_to eq( '' )
    #      expect( subject.get_swimmer_name ).not_to eq( '?' )
    #      expect( subject.get_swimmer_name.size ).to be > 3
    #    end
    #    it "returns always a string with at least 2 words separated by a space" do
    #      expect( subject.get_swimmer_name.split(' ').size ).to be >= 2
    #    end
  end

  # THIS example has more to do with validation than actual method basic functionality.
  # TODO make a dedicated method to validate/check the result (#is_swimmer_age_valid?)
  # TODO this will be its spec:
  #  describe "#get_swimmer_age" do
  #    it "returns always a value between 8 and 120" do
  #      expect( subject.get_swimmer_age ).to be > 8
  #      expect( subject.get_swimmer_age ).to be < 120
  #    end
  #  end
  #-- -------------------------------------------------------------------------
  #++

  # Should retrieve the array of all recent & available categories for
  # which the swimmer is eligible of association, using only the defined
  # year of birth.
  # (Does not need any valid association on the Swimmer side).
  #
  # FIXME
  # Leega: Verify presence of season as requested parameter
  # Steve: I skipped the need of any season parameter; we can do a dedicated method instead, if you think this is required
  describe '#get_swimmer_current_category_type_codes' do
    it 'returns always a valid array' do
      expect(subject.get_swimmer_current_category_type_codes).to be_an_instance_of(Array)
    end
  end

  # THIS example has more to do with validation than actual method basic functionality.
  # TODO make a dedicated method to validate/check the result (#is_category_type_valid?)
  # TODO this will be its spec:

  # Should retrieve the last among all recent & available categories for
  # which the swimmer is eligible of association, using only the defined
  # year of birth.
  # (Does not need any valid association on the Swimmer side).
  #
  # FIXME
  # Leega: Verify presence of season as requested parameter
  # Steve: I skipped the need of any season parameter; we can do a dedicated method instead, if you think this is required
  #  describe "#get_swimmer_current_category" do
  #    it "returns a string value for the category_type" do
  #      expect( subject.get_swimmer_current_category ).to be_an_instance_of( String )
  #    end
  #    it "returns always a valid category_type value" do
  #      expect(
  #        CategoryType.select(:code).all.distinct.any?{ |row|
  #          row.code == subject.get_swimmer_current_category
  #        }
  #      ).to be true
  #    end
  #  end
  #-- -------------------------------------------------------------------------
  #++
end
