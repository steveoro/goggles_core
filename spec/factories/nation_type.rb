require 'ffaker'

FactoryBot.define do
  factory :nation_type do
    # XXX [Steve] since the code must be UNIQUE, it must be different upon
    #             each call:
    code         { (rand * 1_000).to_i.to_s }
    numeric_code { (rand * 1_000).to_i }
    alpha2_code  { code[0..1] }

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
end
