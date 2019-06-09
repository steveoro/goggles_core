# frozen_string_literal: true

require 'rails_helper'

describe TeamPassageTemplate, type: :model do
  # Assumes in test environment exists at least one team with passage templates
  let(:pool_type)  { PoolType.only_for_meetings[(rand * (PoolType.only_for_meetings.count - 1)).to_i] }
  let(:event_type) { EventType.for_fin_calculation[(rand * (EventType.for_fin_calculation.count - 1)).to_i] }
  let(:distance)   { event_type.length_in_meters }
  let(:team)       { TeamPassageTemplate.all[(rand * (TeamPassageTemplate.count - 1)).to_i].team }

  context '[a well formed instance]' do
    subject { create(:team_passage_template) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end

    it_behaves_like('(belongs_to required models)', [:team, :event_type, :pool_type, :passage_type])

    it_behaves_like('(the existance of a class method)', [:get_default_passage_types_for, :get_template_passage_types_for])
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_default_passage_types_for' do
      it 'returns an array' do
        expect(subject.class.get_default_passage_types_for(distance, pool_type.length_in_meters)).to be_a_kind_of(Array)
      end
      it 'returns an array for passage types' do
        expect(subject.class.get_default_passage_types_for(distance, pool_type.length_in_meters)).to all(be_an_instance_of(PassageType))
      end
      it 'returns an array for passage types sorted by distance' do
        passage_types = subject.class.get_default_passage_types_for(distance, pool_type.length_in_meters)
        previous_distance = passage_types[0].length_in_meters
        passage_types.each do |passage_type|
          expect(passage_type.length_in_meters).to be >= previous_distance
          previous_distance = passage_type.length_in_meters
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_template_passage_types_for' do
      it 'returns an array' do
        expect(subject.class.get_template_passage_types_for(team, event_type, pool_type)).to be_a_kind_of(Array)
      end
      it 'returns an array for passage types' do
        expect(subject.class.get_template_passage_types_for(team, event_type, pool_type)).to all(be_an_instance_of(PassageType))
      end
      it 'returns an empty array if no passage templates' do
        expect(subject.class.get_template_passage_types_for(create(:team), event_type, pool_type).size).to eq(0)
      end
      it 'returns a non empty array if passage templates exist' do
        fix_pool = team.team_passage_templates[(rand * (team.team_passage_templates.count - 1)).to_i].pool_type
        fix_event = team.team_passage_templates.for_pool_type(fix_pool)[(rand * (team.team_passage_templates.for_pool_type(fix_pool).count - 1)).to_i].event_type
        expect(subject.class.get_template_passage_types_for(Team.find(1), fix_event, fix_pool).size).to be > 0
      end
      it 'returns an array for passage types sorted by distance' do
        fix_pool = team.team_passage_templates[(rand * (team.team_passage_templates.count - 1)).to_i].pool_type
        fix_event = team.team_passage_templates.for_pool_type(fix_pool)[(rand * (team.team_passage_templates.for_pool_type(fix_pool).count - 1)).to_i].event_type
        passage_types = subject.class.get_template_passage_types_for(Team.find(1), fix_event, fix_pool)
        previous_distance = passage_types[0].length_in_meters
        passage_types.each do |passage_type|
          expect(passage_type.length_in_meters).to be >= previous_distance
          previous_distance = passage_type.length_in_meters
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
