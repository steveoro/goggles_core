# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :region_type do
    code        { FFaker::Lorem.word.to_s[0..2] }
    name        { FFaker::Lorem.word }

    nation_type do
      if NationType.count > 0
        NationType.all.min { rand - 0.5 }
      else
        create(:nation_type)
      end
    end

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end
  end
end
