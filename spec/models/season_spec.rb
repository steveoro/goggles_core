require 'spec_helper'
require 'date'

describe Season, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "UserRelatable"

  describe "[a non-valid instance]" do
    it "is not a valid season without description" do
      expect( build(:season, description: nil) ).not_to be_valid
    end
    it "is not a valid season without header_year" do
      expect( build(:season, header_year: nil) ).not_to be_valid
    end
    it "is not a valid season with incorrect header_year" do
      expect( build(:season, header_year: "More_than_9_char_string") ).not_to be_valid
    end
    it "is not a valid season without edition" do
      expect( build(:season, edition: nil) ).not_to be_valid
    end
    it "is not a valid season with incorrect edition" do
      expect( build(:season, edition: 1234567890) ).not_to be_valid
    end
    it "is not a valid season without begin_date" do
      # Should pass end_date and header_year, calculated from begin_date
      expect( build(:season, begin_date: nil, end_date: Date.parse('2014-06-15'), header_year: 2014) ).not_to be_valid
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "[SeasonFactoryTools.get_season_with_full_categories()]" do
    subject do
      SeasonFactoryTools.get_season_with_full_categories()
    end

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has several category_types" do
      expect( subject.category_types.count ).to be > 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "[a well formed instance]" do
    subject { create( :season ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :season_type,
      :timing_type,
      :edition_type
    ])
    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :sort_season_by_begin_date,
      :sort_season_by_season_type,
      :sort_season_by_user
    ])
    it_behaves_like( "(the existance of a method)", [
      :get_full_name,
      :get_verbose_name,
      :is_season_ended_at,
      :is_season_started_at,
      :get_season_type,
      :get_federation_type,
      :get_last_season_by_type,
      :build_header_year
    ])

    describe "#get_full_name" do
      it "returns the correct full description" do
        expect( subject.get_full_name ).to be_an_instance_of( String )
        expect( subject.get_full_name ).not_to eq( '' )
        expect( subject.get_full_name ).not_to eq( '?' )
      end
    end

    describe "#get_verbose_name" do
      it "returns the correct verbose description" do
        expect( subject.get_verbose_name ).to be_an_instance_of( String )
        expect( subject.get_verbose_name ).not_to eq( '' )
        expect( subject.get_verbose_name ).not_to eq( '?' )
      end
    end

    describe "#is_season_ended_at" do
      it "evaluates the given date" do
        expect( subject.is_season_ended_at( subject.end_date + 365 ) ).to be true
        expect( subject.is_season_ended_at( subject.end_date - 365 ) ).to be false

        subject.begin_date = Date.today - 465
        subject.end_date = Date.today - 100
        expect( subject.is_season_ended_at() ).to be true

        subject.begin_date = Date.today - 265
        subject.end_date = Date.today + 100
        expect( subject.is_season_ended_at() ).to be false

        subject.end_date = nil
        expect( subject.is_season_ended_at(Date.parse('2025-12-31')) ).to be false
        expect( subject.is_season_ended_at(Date.parse('1999-01-01')) ).to be false
        expect( subject.is_season_ended_at() ).to be false
      end
    end

    describe "#is_season_started_at" do
      it "evaluates the given date" do
        expect( subject.is_season_started_at( subject.begin_date + 365 ) ).to be true
        expect( subject.is_season_started_at( subject.begin_date - 365 ) ).to be false

        subject.begin_date = Date.today - 200
        expect( subject.is_season_started_at() ).to be true

        subject.begin_date = Date.today + 100
        expect( subject.is_season_started_at() ).to be false
      end
    end

    describe "#get_season_type" do
      it "returns the correct season type" do
        expect( subject.get_season_type ).to be_an_instance_of( String )
        expect( subject.get_season_type ).not_to eq( '' )
        expect( subject.get_season_type ).not_to eq( '?' )
      end
    end

    describe "#get_federation_type" do
      it "returns the correct fedeation type" do
        expect( subject.get_federation_type ).to be_an_instance_of( String )
        expect( subject.get_federation_type ).not_to eq( '' )
        expect( subject.get_federation_type ).not_to eq( '?' )
      end
    end

    describe "#get_last_season_by_type" do
      it "returns the latest season according to current season_type" do
        expect( subject.get_last_season_by_type( subject.season_type.code ) ).to be_a( Season )
        create(
          :season,
          description: "Older season",
          edition: subject.edition - 1,
          begin_date: subject.begin_date - 365,
          end_date: subject.end_date - 365,
          season_type: subject.season_type
        )
        seasonnewer = create(
          :season,
          description: "Newer season",
          edition: subject.edition + 1,
          begin_date: subject.begin_date + 30065,
          end_date: subject.end_date + 30065,
          season_type: subject.season_type
        )
        expect( subject.get_last_season_by_type( subject.season_type.code ) ).to eq( seasonnewer )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#build_header_year" do
      it "returns always a string" do
        expect( subject.build_header_year ).to be_an_instance_of( String )
      end
      it "contains the begin year and the end year in the result" do
        expect( subject.build_header_year ).to include( subject.begin_date.year.to_s )
        expect( subject.build_header_year ).to include( subject.end_date.year.to_s )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.build_header_year_from_date" do
      it "returns always a string" do
        expect( Season.build_header_year_from_date ).to be_an_instance_of( String )
      end
      it "contains the year of the specified date in the result" do
        date = Date.parse("#{ 2000 + ((rand * 100) % 15).to_i }-09-01")
        expect( Season.build_header_year_from_date( date ) ).to include( date.year.to_s )
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    context "[season result methods]" do
      xit "has a method to determine the season athlete charts"
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
