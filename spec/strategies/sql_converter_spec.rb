# encoding: utf-8

require 'spec_helper'
require 'sql_converter'


describe SqlConverter, type: :strategy do

  subject do
    class Dummy
      include SqlConverter
    end
    Dummy.new
  end

  let(:record)   { create( :training ) }

  context "as an included module," do
    it_behaves_like( "SqlConverter [param: let(:record)]" )
  end
  #-- -------------------------------------------------------------------------
  #++
end
