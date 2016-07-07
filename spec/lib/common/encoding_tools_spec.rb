# encoding: utf-8

require 'rails_helper'

# [Steve, 20140925] we must use a relative path for sake of CI server happyness:
require_relative '../../../lib/common/encoding_tools'


describe EncodingTools, type: :model do

  describe "self.force_valid_encoding" do
    [
      "SARÀ SOLO ùnà Pròva",
      "èèà°€ìòçù-TEST-TEST"
    ].each do |fixture_text|
      it "returns a string with a valid character sequence (#{fixture_text})" do
        expect( EncodingTools.force_valid_encoding( fixture_text ) ).to eq( fixture_text )
      end
    end
  end
  #-- -----------------------------------------------------------------------
  #++
end
