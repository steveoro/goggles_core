require 'spec_helper'


describe SwimmingPoolDecorator, type: :model do
  include Rails.application.routes.url_helpers

  subject { SwimmingPool.find( ((rand * 50) % 50).to_i + 1 ).decorate }

  context "[implemented methods]" do
    it_behaves_like "(the existance of a method returning non-empty strings)", [
      :get_verbose_name,
      :get_city_full_name,
      :get_full_address,
      :get_city_and_attributes,
      :get_pool_type,
      :get_pool_attributes,
      :get_locker_cabinet_type,
      :get_shower_type,
      :get_hair_dryer_type
    ]
    it_behaves_like "(the existance of a method)", [
      :get_maps_url
    ]
    it_behaves_like "(the existance of a method returning numeric values)", [
      :get_pool_length_in_meters,
      :get_pool_lanes_number
    ]
  end

  describe "#get_maps_url" do
    it "returns a non-empty string for a pool with an address" do
      expect( subject.get_maps_url ).to be_an_instance_of(String)
      expect( subject.get_maps_url ).to include('maps/')
    end
    it "returns nil for a pool with no address" do
      fix_pool = create(:swimming_pool, address: nil, city: nil)
      expect( fix_pool.decorate.get_maps_url ).to be_nil
    end
  end

  describe "#get_pool_length_in_meters" do
    it "returns a number between 0 and 50" do
      expect( subject.get_pool_length_in_meters ).to be >= 0
      expect( subject.get_pool_length_in_meters ).to be <= 50
    end
  end

  describe "#get_pool_lanes_number" do
    it "returns a number between 0 and 10" do
      expect( subject.get_pool_lanes_number ).to be >= 0
      expect( subject.get_pool_lanes_number ).to be <= 10
    end
  end

  describe "#get_linked_name" do
    it "returns a string" do
      expect( subject.get_linked_name ).to be_a_kind_of( String )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_name ).to include( 'href' )
    end
    it "returns an HTML link to the swimming pool path" do
      expect( subject.get_linked_name ).to include( swimming_pool_path(id: subject.id) )
    end
    it "returns a string containing the swimming pool name" do
      expect( subject.get_linked_name ).to include( ERB::Util.html_escape(subject.get_verbose_name) )
    end
    it "returns a string containing the swimming pool choosen type name" do
      expect( subject.get_linked_name( :get_full_name ) ).to include( ERB::Util.html_escape(subject.get_full_name) )
    end
  end
end
