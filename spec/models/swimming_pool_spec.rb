# frozen_string_literal: true

require 'rails_helper'

describe SwimmingPool, type: :model do
  describe '[a non-valid instance]' do
    it_behaves_like('(missing required values)', [:name, :nick_name, :lanes_number])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '[a well formed instance]' do
    subject { create(:swimming_pool) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:city, :pool_type])

    it 'has a valid city' do
      expect(subject.city).to be_an_instance_of(City)
    end
    it 'has a valid pool type' do
      expect(subject.pool_type).to be_an_instance_of(PoolType)
    end

    context '[general methods]' do
      it_behaves_like('(the existance of a method)', [
                        # Fields:
                        :name, :nick_name,
                        :address, :phone_number, :fax_number, :e_mail, :contact_name,
                        :lanes_number,
                        :has_multiple_pools, :has_open_area, :has_bar, :has_restaurant_service,
                        :has_gym_area, :has_children_area,
                        :do_not_update,
                        # Methods:
                        :get_pool_length_in_meters,
                        :get_pool_lanes_number,
                        :get_pool_attributes
                      ])

      it_behaves_like('(the existance of a method returning non-empty strings)', [
                        # Semi-standard:
                        :get_full_name,
                        :get_verbose_name,
                        :get_city_full_name,
                        :get_full_address,
                        :get_city_and_attributes,
                        # Delegation:
                        :user_name,
                        :city_name,
                        # Localization:
                        :i18n_short, :get_full_name,
                        :i18n_description, :get_verbose_name
                      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_city_and_attributes' do
    context 'when city is nil,' do
      let(:fixture_pool_with_no_city) { FactoryBot.create(:swimming_pool, city_id: nil) }

      it 'returns a String' do
        expect(fixture_pool_with_no_city.get_city_and_attributes).to be_a(String)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
