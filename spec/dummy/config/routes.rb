Rails.application.routes.draw do

  mount GogglesCore::Engine => "/"

  root :to => 'home#index'

  scope "/" do
    # === Home ===
    # Mounting and usage of the Engine:
    match "index",            to: "home#index"
    match "restricted_info",  to: "home#restricted_info"
  end
end
