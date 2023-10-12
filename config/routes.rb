Rails.application.routes.draw do
  scope 'docs' do
    get 'accordion', to: 'docs#accordion', as: :docs_accordion
    get 'alert', to: 'docs#alert', as: :docs_alert
    get 'link', to: 'docs#link', as: :docs_link
    get 'typography', to: 'docs#typography', as: :docs_typography
  end
  root "pages#home"
end
