# frozen_string_literal: true

require 'rails_helper'

describe Swimmer, type: :model do
  describe '[a non-valid instance]' do
    it_behaves_like('(missing required values)', [:complete_name, :year_of_birth])
  end
  #-- -------------------------------------------------------------------------
  #++

  it_behaves_like 'DropDownListable'

  it_behaves_like('(the existance of a class method)', [
                    # Filtering scopes:
                    :is_male,
                    :is_female,
                    :has_results,
                    # Other class methods:
                    :get_label_symbol,
                    :get_team_names
                  ])
  #-- -----------------------------------------------------------------------
  #++

  describe '[a well formed instance]' do
    subject { create(:swimmer) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated (owned foreign-key) relations:
    it_behaves_like('(belongs_to required models)',
                    [:user, :gender_type])
    # Test the existance of all the required has_many / has_one relationships:
    it_behaves_like('(the existance of a method returning a collection of some kind of instances)',
                    [:user_swimmer_confirmations, :badges, :teams, :category_types, :goggle_cups, :season_types, :meeting_individual_results, :meeting_relay_swimmers, :meeting_relay_results, :meeting_sessions, :meetings, :user_results],
                    ActiveRecord::Base)

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)',
                      [:complete_name, :get_full_name, :get_full_name_with_nickname, :get_verbose_name])
      it_behaves_like('(the existance of a method returning a boolean value)',
                      [:is_male, :is_female])
    end
    # ---------------------------------------------------------------------------
    #++

    describe '#get_badges_array_for_year' do
      it 'returns always a processable list' do
        expect(subject.get_badges_array_for_year).to respond_to(:each)
        expect(subject.get_badges_array_for_year).to respond_to(:count)
      end
      it 'returns a list of Badge rows for a Swimmer w/ badges' do
        swimmer = Swimmer.find(142)
        result = swimmer.get_badges_array_for_year
        expect(result).to all(be_an_instance_of(Badge))
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#has_badge_for_season_and_year?' do
      it 'returns a boolean' do
        expect(subject.has_badge_for_season_and_year?).to eq(true).or eq(false)
      end
      it 'returns true if swimmer has badge for FIN season' do
        swimmer = Swimmer.find(23)
        expect(swimmer.has_badge_for_season_and_year?(header_year = 2014)).to be true
      end
      it 'returns true if swimmer has badge for CSI season but not FIN' do
        swimmer = Swimmer.find(23)
        season_type = SeasonType.find_by(code: 'MASCSI')
        expect(swimmer.has_badge_for_season_and_year?(header_year = 2002, season_type = season_type)).to be true
      end
      it "returns false if swimmer hasn't badge for FIN season but CSI" do
        swimmer = Swimmer.find(23)
        expect(swimmer.has_badge_for_season_and_year?(header_year = 2002)).to be false
      end
      it "returns false if swimmer hasn't badge for FIN season" do
        swimmer = Swimmer.find(23)
        expect(swimmer.has_badge_for_season_and_year?(header_year = 1970)).to be false
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '[a fixture w/ full, valid data]' do
    subject { Swimmer.find([23, 142].min { rand - 0.5 }) }

    describe '#get_total_meters_swam' do
      it 'returns a number greater than 0' do
        expect(subject.get_total_meters_swam).to be > 0
      end
    end

    describe '#get_total_time_swam' do
      it 'returns a Timing instance' do
        expect(subject.get_total_time_swam).to be_a(Timing)
      end
      it 'returns a positive value (in hundreds)' do
        expect(subject.get_total_time_swam.to_hundreds).to be > 0
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_first_meeting' do
      it 'returns a Meeting' do
        expect(subject.get_first_meeting).to be_a(Meeting)
      end
    end

    describe '#get_last_meeting' do
      it 'returns a Meeting' do
        expect(subject.get_last_meeting).to be_a(Meeting)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_best_individual_result' do
      it 'returns a MeetingIndividualResult' do
        expect(subject.get_best_individual_result).to be_a(MeetingIndividualResult)
      end
    end

    describe '#get_worst_individual_result' do
      it 'returns a MeetingIndividualResult' do
        expect(subject.get_worst_individual_result).to be_a(MeetingIndividualResult)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_swimmer_age' do
      it 'returns a number' do
        expect(subject.get_swimmer_age).to be > 0
      end
      it 'returns the years between swimmer year of birth and current date' do
        year_of_birth = subject.year_of_birth
        today = Date.today
        year_of_date = today.year
        expect(year_of_birth).to be >= 1900
        expect(year_of_date).to be > year_of_birth
        # expect( subject.get_swimmer_age( today ) ).to be_equal( year_of_date - year_of_birth )
        expect(subject.get_swimmer_age).to be_equal(year_of_date - year_of_birth)
      end
      it 'returns the years between swimmer year of birth and given date' do
        year_of_birth = subject.year_of_birth
        given_date = Date.parse("#{2010 + ((rand * 100) % 15).to_i}-09-01")
        year_of_date = given_date.year
        expect(year_of_birth).to be >= 1900
        expect(year_of_date).to be > year_of_birth
        expect(subject.get_swimmer_age(given_date)).to be_equal(year_of_date - year_of_birth)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    # TODO: Add more specs for all the other methods
  end
  #-- -------------------------------------------------------------------------
  #++
end
