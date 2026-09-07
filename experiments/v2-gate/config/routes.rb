Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # /gate/dialog_default, /gate/dialog_open, ... — one route per scenario view.
  get "gate/:scenario", to: "gate#show", as: :gate
end
