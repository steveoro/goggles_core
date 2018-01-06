require 'ffaker'

FactoryBot.define do

  factory :area_type do
    code        { "#{FFaker::Lorem.word}"[0..2] }
    name        { FFaker::Lorem.word }

    region_type do
      if RegionType.count > 0
        RegionType.all.sort{rand - 0.5}.first
      else
        create(:region_type)
      end
    end

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
end
