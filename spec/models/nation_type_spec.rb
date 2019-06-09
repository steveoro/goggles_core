# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NationType, type: :model do
  it_behaves_like 'DropDownListable'
  it_behaves_like 'Localizable'

  context '[a well formed instance]' do
    subject { create(:nation_type) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
  end
end
