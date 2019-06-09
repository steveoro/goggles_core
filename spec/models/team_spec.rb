# frozen_string_literal: true

require 'rails_helper'

describe Team, type: :model do
  describe '[a non-valid instance]' do
    it_behaves_like('(missing required values)', [:name, :editable_name])
  end
  #-- -------------------------------------------------------------------------
  #++

  it_behaves_like 'DropDownListable'

  it_behaves_like('(the existance of a class method)', [
                    # Filtering scopes:
                    :has_results,
                    :has_many_results,
                    # Other class methods:
                    :get_label_symbol,
                    :get_swimmer_ids_for
                  ])
  #-- -----------------------------------------------------------------------
  #++

  describe 'self.get_swimmer_ids_for' do
    context 'with valid parameters,' do
      # TODO: Randomize these fixtures (Choose a random meeting, select a random team among them, use their IDs)
      subject { Team.get_swimmer_ids_for(1, 15_205) }
      it 'returns a list of IDs' do
        expect(subject).to be_an(Array)
        expect(subject.size).to be > 0
        expect(subject).to all be_a(Fixnum)
      end
    end

    context 'with a nil team_id,' do
      subject { Team.get_swimmer_ids_for(nil, 15_205) }
      it 'returns an empty Array' do
        expect(subject).to eq([])
      end
    end

    context 'with a valid team_id and a nil meeting_id,' do
      subject { Team.get_swimmer_ids_for(1, nil) }
      it 'returns an empty Array' do
        expect(subject).to eq([])
      end
    end

    context 'with a valid team_id and a non-existing meeting_id,' do
      subject { Team.get_swimmer_ids_for(1, 0) }
      it 'returns an empty Array' do
        expect(subject).to eq([])
      end
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  describe '[a well formed instance]' do
    subject { Team.find(1) }
    #    subject { create( :team ) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated (owned foreign-key) relations:
    it_behaves_like('(belongs_to required models)', [:city])
    # Test the existance of all the required has_many / has_one relationships:
    it_behaves_like('(the existance of a method returning a collection of some kind of instances)',
                    [:badges, :swimmers, :meeting_individual_results, :meetings, :seasons, :meeting_relay_results, :meeting_team_scores, :team_affiliations, :seasons, :season_types, :team_managers, :goggle_cups, :computed_season_ranking],
                    ActiveRecord::Base)

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)',
                      [:get_full_name, :get_verbose_name])
      it_behaves_like('(the existance of a method returning a boolean value)',
                      [
                        :has_goggle_cup_at?
                      ])
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#has_goggle_cup_at?' do
      it 'accepts a date as a parameter' do
        result = subject.has_goggle_cup_at?(Date.today)
        if result
          expect(result).to be true
        else
          expect(result).to be false
        end
      end
      it 'returns true for CSI Ober Ferrari at 01/01/2014' do
        fix_date = Date.parse('2014-01-01')
        expect(subject.has_goggle_cup_at?(fix_date)).to be true
      end
      it 'returns false for CSI Ober Ferrari at 01/01/1990' do
        fix_date = Date.parse('1990-01-01')
        expect(subject.has_goggle_cup_at?(fix_date)).to be false
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_current_goggle_cup_at' do
      it 'responds to #get_current_goggle_cup_at' do
        expect(subject).to respond_to(:get_current_goggle_cup_at)
      end
      context 'without parameters' do
        it 'returns an instance of goggle_cup or nil' do
          expect(subject.get_current_goggle_cup_at).to be_an_instance_of(GoggleCup).or be_nil
        end
      end
      context 'with a date as parameter' do
        it 'returns an instance of goggle_cup or nil' do
          fix_date = Date.today
          expect(subject.get_current_goggle_cup_at(fix_date)).to be_an_instance_of(GoggleCup).or be_nil
        end
        it 'returns an instance of goggle_cup for CSI Ober Ferrari at 01-01-2014' do
          fix_date = Date.parse('2014-01-01')
          expect(subject.get_current_goggle_cup_at(fix_date)).to be_an_instance_of(GoggleCup)
        end
        it 'returns Ober Cup 2014 for CSI Ober Ferrari at 01-01-2014' do
          fix_date = Date.parse('2014-01-01')
          expect(subject.get_current_goggle_cup_at(fix_date).get_full_name).to include('Ober Cup 2014')
        end
        it 'returns nil for CSI Ober Ferrari at 01-01-1990' do
          fix_date = Date.parse('1990-01-01')
          expect(subject.get_current_goggle_cup_at(fix_date)).to be_nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_current_goggle_cup_name_at' do
      it 'responds to #get_current_goggle_cup_name_at' do
        expect(subject).to respond_to(:get_current_goggle_cup_name_at)
      end
      context 'without parameters' do
        it 'returns a string' do
          expect(subject.get_current_goggle_cup_name_at).to be_an_instance_of(String)
        end
      end
      context 'with a date as parameter' do
        it 'returns a string' do
          fix_date = Date.today
          expect(subject.get_current_goggle_cup_name_at(fix_date)).to be_an_instance_of(String)
        end
        it 'returns Ober Cup 2014 for CSI Ober Ferrari at 01-01-2014' do
          fix_date = Date.parse('2014-01-01')
          expect(subject.get_current_goggle_cup_name_at(fix_date)).to include('Ober Cup 2014')
        end
        it 'returns generic Goggle Cup for CSI Ober Ferrari at 01-01-1990' do
          fix_date = Date.parse('1990-01-01')
          expect(subject.get_current_goggle_cup_name_at(fix_date)).to eq('Goggle cup')
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_current_affiliation' do
      it 'responds to #get_current_affiliationt' do
        expect(subject).to respond_to(:get_current_affiliation)
      end
      context 'without parameters' do
        it 'returns an instance of team affiliation or nil' do
          expect(subject.get_current_affiliation).to be_an_instance_of(TeamAffiliation).or be_nil
        end
      end
      context 'with a season type as parameter' do
        it 'returns an instance of goggle_cup or nil' do
          fix_season_type = SeasonType.all[((rand * SeasonType.count) % SeasonType.count).to_i]
          expect(subject.get_current_affiliation(fix_season_type)).to be_an_instance_of(TeamAffiliation).or be_nil
        end
        # XXX Since the team affiliation is currently created by hand at the beginning
        # of the academic year, there's a small gap of several weeks in which this
        # test may fail. Thus, the additional check on the current date.
        it "returns a valid team affiliation for CSI Ober Ferrari during the 'academic year'" do
          fix_season_type = SeasonType.find_by(code: 'MASFIN')
          # This is the range of months inside which we are actually expecting the
          # affiliation to be defined:
          if Date.today.month.in?(1..6) || Date.today.month.in?(11..12)
            expect(subject.get_current_affiliation(fix_season_type)).to be_an_instance_of(TeamAffiliation)
          end
        end
        it 'returns nil for newly created team' do
          fix_team = create(:team)
          fix_season_type = SeasonType.all[((rand * SeasonType.count) % SeasonType.count).to_i]
          expect(fix_team.get_current_affiliation(fix_season_type)).to be_nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
