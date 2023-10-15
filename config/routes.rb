Rails.application.routes.draw do
  scope 'docs' do
    get 'accordion', to: 'docs#accordion', as: :docs_accordion
    get 'alert', to: 'docs#alert_component', as: :docs_alert # alert is a reserved word for controller action
    get 'alert_dialog', to: 'docs#alert_dialog', as: :docs_alert_dialog
    get 'aspect_ratio', to: 'docs#aspect_ratio', as: :docs_aspect_ratio
    get 'avatar', to: 'docs#avatar', as: :docs_avatar
    get 'badge', to: 'docs#badge', as: :docs_badge
    get 'button', to: 'docs#button', as: :docs_button
    get 'card', to: 'docs#card', as: :docs_card
    get 'checkbox', to: 'docs#checkbox', as: :docs_checkbox
    get 'collapsible', to: 'docs#collapsible', as: :docs_collapsible
    get 'dialog', to: 'docs#dialog', as: :docs_dialog
    get 'link', to: 'docs#link', as: :docs_link
    get 'tabs', to: 'docs#tabs', as: :docs_tabs
    get 'theme_toggle', to: 'docs#theme_toggle', as: :docs_theme_toggle
    get 'typography', to: 'docs#typography', as: :docs_typography
  end
  root "pages#home"
end
