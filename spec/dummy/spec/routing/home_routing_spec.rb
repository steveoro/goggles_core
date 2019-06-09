# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/')).to route_to('home#index')
      expect(get('/home/index')).to route_to('home#index')
      expect(get(home_index_path)).to route_to('home#index')
    end

    it 'routes to #restricted_info' do
      expect(get('/home/restricted_info')).to route_to('home#restricted_info')
      expect(get(home_restricted_info_path)).to route_to('home#restricted_info')
    end
  end
end
