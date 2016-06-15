require 'spec_helper'


shared_examples_for "(existance of a member array)" do |member_name_array|
  member_name_array.each do |member_name|
    it "responds to ##{ member_name }" do
      expect( subject ).to respond_to( member_name )
    end

    it "has a ##{ member_name } array" do
      expect( subject.send(member_name.to_sym) ).to be_a_kind_of( Array )
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
