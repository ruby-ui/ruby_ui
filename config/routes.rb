Rails.application.routes.draw do
  scope '/docs' do
    get 'link', to: 'docs#link', as: :docs_link
    get 'typography', to: 'docs#typography', as: :docs_typography
  end
  root "pages#home"
end
