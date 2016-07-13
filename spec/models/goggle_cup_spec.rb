require 'rails_helper'


describe GoggleCup, :type => :model do
  # Force Ober cup 2014 for CSI Ober Ferrari
  let( :fix_goggle_cup )   { GoggleCup.find(8) }

  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [
      :description,
      :season_year,
      :max_points,
      :max_performance
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "[a well formed instance]" do
    #subject { GoggleCup.find(1) }
    #subject { create( :goggle_cup ) }
    subject { create( :goggle_cup_with_definitions ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # Validated (owned foreign-key) relations:
    it_behaves_like( "(belongs_to required models)", [
       :team
    ])

    # Test the existance of all the required has_many / has_one relationships:
    it_behaves_like( "(the existance of a method returning a collection of some kind of instances)",
      [
        :goggle_cup_definitions,
        :goggle_cup_standards,
        :seasons,
        :meetings,
        :meeting_individual_results
      ],
      ActiveRecord::Base
    )

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :sort_goggle_cup_by_user,
      :sort_goggle_cup_by_team,
      :is_closed_now,
      :is_current,
      :for_team
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name,
        :get_verbose_name
      ])

      it_behaves_like( "(the existance of a method returning a date)", [
        :get_begin_date,
        :get_end_date
      ])

      it_behaves_like( "(the existance of a method returning a boolean value)", [
        :is_closed_at?,
        :is_current_at?,
        :has_results?
      ])

      it_behaves_like( "(the existance of a method returning an array)", [
        :calculate_goggle_cup_rank
      ])
    end
    # ---------------------------------------------------------------------------
    #++

    describe "self.for_team" do
      context "for a Team with existing GoggleCups," do
        it "returns a list of GoggleCups" do
          team = Team.find( 1 ) # This surely has some GoggleCup defined
          expect( subject.class.for_team(team) ).to all be_a( GoggleCup )
        end
      end
      context "for a Team with NO GoggleCups," do
        it "returns an empty list" do
          team = create( :team )
          expect( subject.class.for_team(team) ).to be_empty
        end
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "self.has_team_goggle_cup_for_season" do
      it "responds to #has_team_goggle_cup_for_season" do
        expect( subject.class ).to respond_to( :has_team_goggle_cup_for_season? )
      end
      it "returns a boolean" do
        fix_team_id   = ((rand * 100) % 30).to_i + 1
        fix_season_id = ((rand * 100) % 20).to_i + 1
        result = subject.class.has_team_goggle_cup_for_season?(fix_team_id, fix_season_id)
        if result
          expect( result == true ).to be true
        else
          expect( result == false ).to be true
        end
      end
      it "returns true if goggle cup present" do
        # Assumes CSI Ober Ferrari, Campionato regionale CSI 2013/2014
        fix_team_id   = 1
        fix_season_id = 131
        expect( subject.class.has_team_goggle_cup_for_season?(fix_team_id, fix_season_id) ).to be true
      end
      it "returns false if goggle cup not present" do
        # Assumes id given doesn't exists
        wrong_team_id   = 12456
        wrong_season_id = 56897
        expect( subject.class.has_team_goggle_cup_for_season?(wrong_team_id, wrong_season_id) ).to be false
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#get_begin_date" do
      xit "returns the earliest begin date of seasons in goggle_cup_definition" do
        found_date = subject.get_begin_date
        subject.seasons.each do |season|
          expect( season.begin_date ).to be >= found_date
        end
      end
      xit "returns the expected begin date" do
        fix_today = Date.today
        fix_tomorrow = fix_today + 1
        fix_date = fix_today - ((rand * 100) + 1)
        fix_goggle_cup = create( :goggle_cup )
        fix_season1 = create( :season, begin_date: fix_tomorrow )
        fix_season2 = create( :season, begin_date: fix_today )
        fix_season3 = create( :season, begin_date: fix_date )
        fix_definition1 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season1.id )
        fix_definition2 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season2.id )
        fix_definition3 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season3.id )
        expect( fix_goggle_cup.get_begin_date.to_s ).to eq( fix_date.to_s )
      end
      it "returns the date at the previous year of goggle_cup end_date" do
        expect( subject.get_begin_date ).to eq( subject.end_date.prev_year )
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#get_end_date" do
      xit "returns the latest end date of seasons in goggle_cup_definition" do
        found_date = subject.get_end_date
        subject.seasons.each do |season|
          expect( season.end_date ).to be <= found_date
        end
      end
      xit "returns the expected end date" do
        fix_today = Date.today
        fix_yesterday = fix_today - 1
        fix_year_ago = fix_today - 364
        fix_date = fix_today + ((rand * 100) + 1)
        fix_goggle_cup = create( :goggle_cup )
        fix_season1 = create( :season, begin_date: fix_year_ago, end_date: fix_yesterday )
        fix_season2 = create( :season, begin_date: fix_year_ago, end_date: fix_today )
        fix_season3 = create( :season, begin_date: fix_year_ago, end_date: fix_date )
        fix_definition1 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season1.id )
        fix_definition2 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season2.id )
        fix_definition3 = create( :goggle_cup_definition, goggle_cup_id: fix_goggle_cup.id, season_id: fix_season3.id )
        expect( fix_goggle_cup.get_end_date.to_s ).to eq( fix_date.to_s )
      end
      it "returns the goggle_cup end_date set on db" do
        expect( subject.get_end_date ).to eq( subject.end_date )
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#is_closed_at?" do
      it "accepts a date as a parameter" do
        fix_date = Date.parse("#{ 2000 + ((rand * 100) % 15).to_i }-09-01")
        result = subject.is_closed_at?( fix_date )
        if result
          expect( result ).to be true
        else
          expect( result ).to be false
        end
      end
      it "returns true if given date is more recent than the latest end date of goggle cup definitions" do
        found_date = subject.get_end_date + ((rand * 100) + 1)
        expect( subject.is_closed_at?( found_date ) ).to be true
      end
      it "returns true if given date is earlier than the latest end date of goggle cup definitions" do
        found_date = subject.get_end_date - ((rand * 100) + 1)
        expect( subject.is_closed_at?( found_date ) ).to be false
      end
      it "returns true if given date is the samer than the latest end date of goggle cup definitions" do
        found_date = subject.get_end_date
        expect( subject.is_closed_at?( found_date ) ).to be false
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#is_current_at?" do
      it "accepts a date as a parameter" do
        fix_date = Date.parse("#{ 2000 + ((rand * 100) % 15).to_i }-09-01")
        result = subject.is_current_at?( fix_date )
        if result
          expect( result ).to be true
        else
          expect( result ).to be false
        end
      end
      it "returns true if given date is between begin and end of season's goggle cup definitions" do
        found_date = subject.get_begin_date + (( subject.get_end_date - subject.get_begin_date ) / 2).to_i
        expect( subject.is_current_at?( found_date ) ).to be true
      end
      it "returns true if given date is the same of goggle cup begin" do
        found_date = subject.get_begin_date
        expect( subject.is_current_at?( found_date ) ).to be true
      end
      it "returns true if given date is the same of goggle cup end" do
        found_date = subject.get_end_date
        expect( subject.is_current_at?( found_date ) ).to be true
      end
      it "returns false if given date is earlier than the begin of goggle cup" do
        found_date = subject.get_begin_date - 1
        expect( subject.is_current_at?( found_date ) ).to be false
      end
      it "returns false if given date is later than the end of goggle cup" do
        found_date = subject.get_end_date + 1
        expect( subject.is_current_at?( found_date ) ).to be false
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#has_results?" do
      it "returns false for an empty goggle cup" do
        expect( subject.has_results? ).to be false
      end
      it "returns true for Ober Cup 2014 of CSI Nuoto Ober Ferrari" do
        expect( fix_goggle_cup.has_results? ).to be true
      end
    end
    # ---------------------------------------------------------------------------
    #++

    describe "#calculate_goggle_cup_rank" do
      context "for a non valid goggle cup" do
        it "assigns an empty array" do
          result = subject.calculate_goggle_cup_rank
          expect( result ).to be_a_kind_of( Array )
          expect( result.size == 0 ).to be true
        end
      end

      context "for a valid goggle cup" do
        it "assigns an empty array" do
          result = fix_goggle_cup.calculate_goggle_cup_rank
          expect( result ).to be_a_kind_of( Array )
          expect( result.size ).to be > 0
        end
        it "assigns an array of hash in which swimmer key contains an instance of Swimmer" do
          fix_goggle_cup.calculate_goggle_cup_rank.each do |element|
            expect( element ).to be_a_kind_of( Hash )
            expect( element[:swimmer] ).to be_an_instance_of( Swimmer )
          end
        end
        it "assigns an array of hash with points to every elements of goggle_cup_rank instance" do
          fix_goggle_cup.calculate_goggle_cup_rank.each do |element|
            expect( element ).to be_a_kind_of( Hash )
            expect( element.has_key?( :total ) ).to be true
            expect( element.has_key?( :average ) ).to be true
            expect( element.has_key?( :min ) ).to be true
            expect( element.has_key?( :max ) ).to be true
            expect( element.has_key?( :count ) ).to be true
          end
        end
        it "assigns an array where count key <= goggle_cup.max_performance" do
          fix_goggle_cup.calculate_goggle_cup_rank.each do |element|
            expect( element[:count] ).to be <= fix_goggle_cup.max_performance
          end
        end
        it "assigns a sorted by total key array" do
          rank_array = fix_goggle_cup.calculate_goggle_cup_rank
          current_item = rank_array.first[:total]
          rank_array.each do |item|
            expect( item[:total] ).to be <= current_item
            current_item = item[:total]
          end
        end
      end
    end
    # ---------------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
