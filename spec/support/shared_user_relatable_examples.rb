require 'rails_helper'


shared_examples_for "UserRelatable" do

  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context "by including this concern" do
    it_behaves_like( "(the existance of a method)",
      [
        :user 
      ]
    )
    
    it_behaves_like( "(the existance of a method returning strings)",
      [
        :user_name,
        :get_user_name
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
