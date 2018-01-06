require 'rails_helper'
require 'wrappers/timing'


shared_examples_for "(the existance of a class method)" do |method_name_array|
  method_name_array.each do |method_name|
    it "responds to ##{method_name}" do
      expect( subject.class ).to respond_to( method_name )
    end
  end
end


shared_examples_for "(the existance of a scope with no parameters)" do |method_name_array|
  it_behaves_like "(the existance of a class method)", method_name_array

  method_name_array.each do |method_name|
    it "returns a kind of ActiveRecord::Relation" do
      expect( subject.class.send(method_name) ).to be_a_kind_of( ActiveRecord::Relation )
    end
  end
end


shared_examples_for "(the existance of a method)" do |method_name_array|
  method_name_array.each do |method_name|
    it "responds to ##{method_name}" do
      expect( subject ).to respond_to( method_name )
    end
  end
end


shared_examples_for "(the existance of a method returning a valid instance)" do |method_name, instance_const|
  describe "##{method_name}" do
    it "responds to ##{method_name}" do
      expect( subject ).to respond_to( method_name )
    end
    it "returns an instance of #{instance_const}" do
      expect( subject.send(method_name) ).to be_an_instance_of( instance_const )
    end
    it "returns a valid instance" do
      expect( subject.send(method_name) ).to be_valid
    end
  end
end


shared_examples_for "(the existance of a method with parameter returning a valid instance or nil)" do |method_name, instance_const, parameter|
  describe "##{method_name}" do
    it "responds to ##{method_name}" do
      expect( subject ).to respond_to( method_name )
    end
    it "returns an instance of #{instance_const}" do
      expect( subject.send(method_name, parameter) ).to be_an_instance_of( instance_const ).or be_nil
    end
  end
end
#-- ---------------------------------------------------------------------------
#++


shared_examples_for "(the existance of a method returning strings)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a String" do
      expect( subject.send(method_name.to_sym) ).to be_an_instance_of( String )
    end
  end
end


shared_examples_for "(the existance of a method returning non-empty strings)" do |method_name_array|
  it_behaves_like "(the existance of a method returning strings)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a non empty string" do
      expect( subject.send(method_name.to_sym) ).not_to eq( '' )
    end
  end
end


shared_examples_for "(the existance of a method returning non-empty and non-? strings)" do |method_name_array|
  it_behaves_like "(the existance of a method returning non-empty strings)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a non-'?' String" do
      expect( subject.send(method_name.to_sym) ).not_to eq( '?' )
    end
  end
end


shared_examples_for "(the existance of a method returning a non-empty Hash)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a non empty Hash" do
      result = subject.send(method_name.to_sym)
      expect( result ).to be_an_instance_of( Hash )
      expect( result.keys ).to be_an_instance_of( Array )
      expect( result.keys.size ).to be > 0
      expect( result.values ).to be_an_instance_of( Array )
      expect( result.values.size ).to be > 0
    end
  end
end


shared_examples_for "(the existance of a method returning a boolean value)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a boolean" do
      result = subject.send(method_name.to_sym)
      if result
        expect( result == true ).to be true
      else
        expect( result == false ).to be true
      end
    end
  end
end
# -----------------------------------------------------------------------------


shared_examples_for "(the existance of a method with parameters, returning String or nil)" do |method_name_array, parameter|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a String value or nil" do
      result = subject.send(method_name.to_sym, parameter)
      if result
        expect( result ).to be_an_instance_of( String )
      else
        expect( result ).to be_nil
      end
    end
  end
end
# -----------------------------------------------------------------------------


shared_examples_for "(the existance of a method with parameters, returning boolean values)" do |method_name_array, parameter|
  it_behaves_like( "(the existance of a method)", method_name_array )
  method_name_array.each do |method_name|
    it "##{method_name} returns a boolean value" do
      result = subject.send(method_name.to_sym, parameter)
      if result
        expect( result == true ).to be true
      else
        expect( result == false ).to be true
      end
    end
  end
end
# -----------------------------------------------------------------------------


shared_examples_for "(the existance of a method returning numeric values)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a numeric value" do
      expect( subject.send(method_name.to_sym) ).to be_a_kind_of( Numeric ).or be_a_kind_of( BigDecimal )
    end
  end
end

shared_examples_for "(the existance of a method with parameters, returning numeric values)" do |method_name_array, parameter|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a numeric value" do
      expect( subject.send(method_name.to_sym, parameter) ).to be_a_kind_of( Numeric ).or be_a_kind_of( BigDecimal )
    end
  end
end
# -----------------------------------------------------------------------------

shared_examples_for "(the existance of a method returning a collection or an object responding to :each)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    describe "##{method_name}" do
      it "returns a collection responding to :each" do
        expect( subject.send(method_name.to_sym) ).to respond_to(:each)
      end
      it "returns a collection responding to :count" do
        expect( subject.send(method_name.to_sym) ).to respond_to(:count)
      end
    end
  end
end

shared_examples_for "(the existance of a method returning a kind of object or nil)" do |method_name_array, object_kind|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    describe "##{method_name}" do
      it "returns a #{object_kind.name} or nil" do
        result = subject.send(method_name.to_sym)
        if result
          expect( result ).to be_an_instance_of( object_kind )
        else
          expect( result ).to be_nil
        end
      end
    end
  end
end

shared_examples_for "(the existance of a method with parameters, returning a kind of object or nil)" do |method_name, object_kind, parameter_kind|
  it_behaves_like "(the existance of a method)", [method_name]
  describe "##{method_name}" do
    let(:fix_parameter) { create( parameter_kind.to_sym ) }
    it "returns a #{object_kind.name} or nil" do
      result = subject.send(method_name.to_sym, fix_parameter)
      if result
        expect( result ).to be_an_instance_of( object_kind )
      else
        expect( result ).to be_nil
      end
    end
  end
end

shared_examples_for "(the existance of a method returning an array)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    describe "##{method_name}" do
      it "returns an Enumerable list" do
        expect( subject.send(method_name.to_sym) ).to be_a_kind_of( Enumerable )
      end
    end
  end
end

shared_examples_for "(the existance of a method returning an Enumerable of non-empty Strings)" do |method_name_array|
  method_name_array.each do |method_name|
    describe "##{method_name}" do
      it "returns an Enumerable list" do
        expect( subject.send(method_name.to_sym) ).to be_a_kind_of( Enumerable )
      end
      it "returns a list of non-empty Strings" do
        subject.send(method_name.to_sym).each do |element|
          expect( element ).to be_an_instance_of( String )
          expect( element.size > 0 ).to be true
        end
      end
    end
  end
end

shared_examples_for "(the existance of a method with parameter returning an Enumerable of non-empty Strings)" do |method_name, parameter|
  describe "##{method_name}" do
    it "returns an Enumerable list" do
      expect( subject.send(method_name.to_sym, parameter) ).to be_a_kind_of( Enumerable )
    end
    it "returns a list of non-empty Strings" do
      subject.send(method_name.to_sym, parameter).each do |element|
        expect( element ).to be_an_instance_of( String )
        expect( element.size > 0 ).to be true
      end
    end
  end
end

shared_examples_for "(the existance of a method returning a collection of some kind of instances)" do |method_name_array, common_kind|
  it_behaves_like "(the existance of a method returning an array)", method_name_array
  method_name_array.each do |method_name|
    describe "##{method_name}" do
      it "returns a collection responding to :each" do
        expect( subject.send(method_name.to_sym) ).to respond_to(:each)
      end
      it "returns a collection responding to :count" do
        expect( subject.send(method_name.to_sym) ).to respond_to(:count)
      end
      it "returns a list of #{common_kind.name}" do
        subject.send(method_name.to_sym).each do |element|
          expect( element ).to be_a_kind_of( common_kind )
        end
      end
    end
  end
end
# -----------------------------------------------------------------------------

shared_examples_for "(the existance of a method returning a date)" do |method_name_array|
  it_behaves_like "(the existance of a method)", method_name_array
  method_name_array.each do |method_name|
    it "##{method_name} returns a date" do
      expect( subject.send(method_name.to_sym) ).to be_an_instance_of( Date )
    end
  end
end
# -----------------------------------------------------------------------------


shared_examples_for "(missing required values)" do |attribute_name_array|
  attribute_name_array.each do |attribute_name|
    it "not a valid instance without ##{attribute_name}" do
      expect( FactoryBot.build(
        subject.class.name.underscore.to_sym,
        attribute_name.to_sym => nil )
      ).not_to be_valid
    end
  end
end


shared_examples_for "(it has_one of these required models)" do |attribute_name_array|
  attribute_name_array.each do |attribute_name|
    it "responds to :#{attribute_name}" do
      expect( subject ).to respond_to( attribute_name )
    end
    it "returns an instance of #{attribute_name.to_s.camelize}" do
      expect( subject.send(attribute_name) ).to be_an_instance_of( attribute_name.to_s.camelize.constantize )
    end
  end
end


shared_examples_for "(belongs_to required models)" do |attribute_name_array|
  attribute_name_array.each do |attribute_name|
    it "it belongs_to :#{attribute_name}" do
      expect( subject.send(attribute_name.to_sym) ).to be_a( eval(attribute_name.to_s.camelize) )
    end
  end
end
# -----------------------------------------------------------------------------

