Rails.application.routes.draw do
  scope '/docs' do
    get 'typography', to: 'docs#typography', as: :docs_typography
  end
  root "pages#home"
end
