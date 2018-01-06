require 'date'
require 'ffaker'


FactoryBot.define do

  # [Steve, 20151215] => WARNING: <=
  #
  #    *** THIS FACTORY REQUIRES A FULL MIR TO CREATE VALID INSTANCES ***
  #
  # To create single and valid passages, either pass an existing MIR (with
  # a valid swimmer and team) or create a new one from scratch with:
  #
  #     create( :meeting_individual_result_with_passages ).passages.first
  #
  factory :passage do
    meeting_individual_result
    meeting_program           { meeting_individual_result.meeting_program }
    minutes                   0
    seconds                   { ((rand * 59) % 59).to_i }  # Forced not to use 59
    hundreds                  { ((rand * 99) % 99).to_i }  # Forced not to use 99
    minutes_from_start        1
    seconds_from_start        { seconds }
    hundreds_from_start       { hundreds }
    position                  { ((rand * 10) % 10).to_i + 1 }
    reaction_time             { rand.round(2) }
    stroke_cycles             { (rand * 20).to_i }
    swimmer                   { meeting_individual_result.swimmer }
    team                      { meeting_individual_result.team }
    user
    # The following column uses the pre-loaded seed records:
    passage_type              { PassageType.all.sort{ rand - 0.5 }[0] }
  end
  #-- -------------------------------------------------------------------------
  #++
end
