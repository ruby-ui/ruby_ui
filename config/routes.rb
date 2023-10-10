Rails.application.routes.draw do
  namespace :components do
    get 'typography', to: 'components#typography'
  end
  root "pages#home"
end
