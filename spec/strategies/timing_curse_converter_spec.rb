require 'rails_helper'


describe TimingCourseConverter, type: :strategy do

  let(:season)      { Season.find(141) }
  let(:gender_type) { GenderType.individual_only[ ((rand * GenderType.individual_only.count) % GenderType.individual_only.count).to_i ] }
  let(:event_type)  { season.event_types[ ((rand * season.event_types.count) % season.event_types.count).to_i ] }

  context "with requested parameters for given season" do

    subject { TimingCourseConverter.new( season ) }

    it_behaves_like( "(the existance of a method)", [
      :get_conversion_table, :get_conversion_value, :convert_time_to_short, :convert_time_to_long, :is_conversion_possible?
    ] )

    describe "#get_conversione_table," do
      it "returns an hash" do
        expect( subject.get_conversion_table ).to be_a_kind_of( Hash )
      end
      it "returns an hash with at least an element" do
        expect( subject.get_conversion_table.size ).to be > 0
      end
      it "returns an hash in which keys are gender and event codes" do
        conversion_table = subject.get_conversion_table
        conversion_table.keys.each do |key|
          expect( GenderType.find_by_code( key.chr ) ).to be_an_instance_of( GenderType )
          expect( EventType.find_by_code( key.slice(1, 6) ) ).to be_an_instance_of( EventType )
        end
      end
      it "returns an hash with keys that returns values" do
        conversion_table = subject.get_conversion_table
        conversion_table.keys.each do |key|
          expect( conversion_table[key] ).to be >= 0
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_conversion_value," do
      it "returns a numeric value" do
        subject.get_conversion_table
        expect( subject.get_conversion_value( gender_type, event_type ) ).to be >= 0
      end
      it "returns 0 if non conversion table set" do
        expect( subject.get_conversion_value( gender_type, EventType.find_by_code("100MI") ) ).to eq( 0 )
      end
      it "returns a value fo male 400SL (seson 141)" do
        subject.get_conversion_table
        expect( subject.get_conversion_value( GenderType.find_by_code("M"), EventType.find_by_code("400SL") ) ).to be > 0
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#convert_time_to_short," do
      before :each do
        @time_swam = Timing.new( ((rand * 25000) % 25000).to_i + 1 )
      end
      
      it "returns a timing instance" do
        expect( subject.convert_time_to_short( @time_swam, gender_type, event_type ) ).to be_an_instance_of( Timing )
      end
      it "returns the same value if no conversion needed" do
        expect( subject.convert_time_to_short( @time_swam, GenderType.find_by_code("X"), event_type ) ).to eq( @time_swam ) 
      end
      it "returns a smaller value if conversion needed" do
        expect( subject.convert_time_to_short( @time_swam, GenderType.find_by_code("M"), EventType.find_by_code("400SL") ).to_hundreds ).to be < @time_swam.to_hundreds 
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#convert_time_to_long," do
      before :each do
        @time_swam = Timing.new( ((rand * 25000) % 25000).to_i + 1 )
      end
      
      it "returns a timing instance" do
        expect( subject.convert_time_to_long( @time_swam, gender_type, event_type ) ).to be_an_instance_of( Timing )
      end
      it "returns the same value if no conversion needed" do
        expect( subject.convert_time_to_long( @time_swam, GenderType.find_by_code("X"), event_type ) ).to eq( @time_swam ) 
      end
      it "returns a greater value if conversion needed" do
        expect( subject.convert_time_to_long( @time_swam, GenderType.find_by_code("M"), EventType.find_by_code("400SL") ).to_hundreds ).to be > @time_swam.to_hundreds 
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#is_conversion_possible?," do
      it "returns true if conversion parameters present" do
        expect( subject.is_conversion_possible?( GenderType.find_by_code("M"), EventType.find_by_code("400SL") ) ).to be true
      end
      it "returns false if conversion parameters not present" do
        expect( subject.is_conversion_possible?( GenderType.find_by_code("X"), EventType.find_by_code("400SL") ) ).to be false
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
end
