# frozen_string_literal: true

require 'rails_helper'

describe City, type: :model do
  it_behaves_like 'DropDownListable'

  context '[a well formed instance]' do
    subject { create(:city) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end

    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:area_type])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_full_name, :get_verbose_name, :area_type_code])
    end
  end
end
