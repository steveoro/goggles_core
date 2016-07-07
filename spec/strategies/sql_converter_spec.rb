# encoding: utf-8

require 'rails_helper'
require 'sql_converter'


class DummySqlConverterIncludee
  include SqlConverter
end


describe SqlConverter, type: :strategy do

  subject do
    DummySqlConverterIncludee.new
  end

  let(:record)   { create( :training ) }

  context "as an included module," do
    it_behaves_like( "SqlConverter [param: let(:record)]" )
  end
  #-- -------------------------------------------------------------------------
  #++
end
