# frozen_string_literal: true

Rails.application.routes.draw do
  mount GogglesCore::Engine => 'home#index'

  root to: 'home#index'

  scope '/' do
    # === Home ===
    # Mounting and usage of the Engine:
    get 'home/index'
    get 'home/restricted_info'
  end
end
