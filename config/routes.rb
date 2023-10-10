Rails.application.routes.draw do
  get 'components/typography', to: 'components#typography', as: 'typography_components'
  root "pages#home"
end
