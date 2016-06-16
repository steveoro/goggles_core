Rails.application.routes.draw do

  mount GogglesCore::Engine => "/"

  root to: 'home#index'

  scope "/" do
    # === Home ===
    # Mounting and usage of the Engine:
    get "home/index"
    get "home/restricted_info"
  end
end
