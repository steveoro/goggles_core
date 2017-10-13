require 'rails_helper'

describe EventType, :type => :model do
  # Assumes presence in seeds
  subject { EventType.all.sort{ rand - 0.5 }[0] }

  it_behaves_like "DropDownListable"

  # Validated relations:
  it_behaves_like( "(belongs_to required models)", [
    :stroke_type
  ])
  # Has_many relationships:
  it_behaves_like( "(the existance of a method returning a collection of some kind of instances)",
    [
      :events_by_pool_types,
      :pool_types
    ],
    ActiveRecord::Base
  )
  # Filtering scopes:
  it_behaves_like( "(the existance of a class method)", [
    :only_relays,
    :are_not_relays,
    :for_fin_calculation,
    :sort_by_style,
    :for_season,
    :for_season_type,
    :for_ironmaster
  ])

  it_behaves_like( "(the existance of a method returning non-empty strings)", [
    :i18n_short,
    :i18n_description,
  ])

  context "class methods" do
    describe "#sort_list_by_style_order" do
      let( :fix_list ) { ["200MI", "50SL", "50FA", "100SL", "200SL"] }

      it "has a class method sort_list_by_style_order" do
        expect( EventType ).to respond_to( :sort_list_by_style_order )
      end
      it "accepts a list as parameter" do
        expect( EventType.sort_list_by_style_order( fix_list ) ).not_to be_nil
      end
      it "returns a list" do
        expect( EventType.sort_list_by_style_order ).to be_a_kind_of( Array )
        expect( EventType.sort_list_by_style_order( fix_list ) ).to be_a_kind_of( Array )
      end
      it "returns full event list sorted if invoked without parameter" do
        expect( EventType.sort_list_by_style_order.join(',') ).to eq(EventType.sort_by_style.map{ |event_type| event_type.code }.join(','))
      end
      it "returns a list with the same number of element" do
        expect( EventType.sort_list_by_style_order( fix_list ).size ).to eq( fix_list.size )
      end
      it "returns a list correctly sorted if invoked with a list" do
        sorted_list = fix_list.sort{ |el_prev, el_next| EventType.find_by_code(el_prev) <=> EventType.find_by_code(el_next) }
        expect( sorted_list.join(',') ).not_to eq(fix_list.join(','))
        expect( sorted_list.join(',') ).to eq( EventType.sort_list_by_style_order( fix_list ).join(',') )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#parse_relay_event_type_from_import_text" do
      [ 50, 100, 200 ].each do |distance_in_meters|
        [
          "mistaffetta 4x#{distance_in_meters} stile libero",
          "staffetta 4x#{distance_in_meters} stile libero  Maschile",
          "staffetta 4x#{distance_in_meters} stile libero  Femminile"
        ].each do |fixture_type_text|
          it "recognizes '#{fixture_type_text}'" do
            result = EventType.parse_relay_event_type_from_import_text(
              StrokeType::FREESTYLE_ID,
              fixture_type_text
            )
            expect( result ).to be_an_instance_of( EventType )
          end
        end
      end

      [ 50, 100 ].each do |distance_in_meters|
        [
          "mistaffetta 4x#{distance_in_meters} mista",
          "staffetta 4x#{distance_in_meters} mista  Maschile",
          "staffetta 4x#{distance_in_meters} mista  Femminile"
        ].each do |fixture_type_text|
          it "recognizes '#{fixture_type_text}'" do
            result = EventType.parse_relay_event_type_from_import_text(
              StrokeType::MIXED_RELAY_ID,
              fixture_type_text
            )
            expect( result ).to be_an_instance_of( EventType )
          end
        end

        [
          "mistaffetta 4x#{distance_in_meters} mista",
          "staffetta 4x#{distance_in_meters} mista  Maschile",
          "staffetta 4x#{distance_in_meters} mista  Femminile"
        ].each do |fixture_type_text|
          it "recognizes '#{fixture_type_text}'" do
            result = EventType.parse_relay_event_type_from_import_text(
              StrokeType::MIXED_ID,
              fixture_type_text
            )
            expect( result ).to be_an_instance_of( EventType )
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
    
    describe "scope for_ironmaster" do
      it "returns 18 elements" do
        expect( EventType.for_ironmaster.count ).to eq( 18 )
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
