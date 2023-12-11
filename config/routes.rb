Rails.application.routes.draw do
  get 'license', to: 'pages#license', as: :license
  get 'support', to: 'pages#support', as: :support

  resource :account, only: [:show, :update]
  resources :team_members, only: [:create, :destroy]

  match "signin/authenticate", to: "signins#authenticate", via: [:get, :post], as: :signin_authenticate
  match "signin/check_your_email", to: "signins#check_your_email", via: [:get, :post], as: :signin_check_your_email
  resource :signin

  resource :webhooks, only: [:create]

  scope 'docs' do
    # GETTING STARTED
    get 'introduction', to: 'docs#introduction', as: :docs_introduction
    get 'installation', to: 'docs#installation', as: :docs_installation
    get 'core_concepts', to: 'docs#core_concepts', as: :docs_core_concepts
    get 'theming', to: 'docs#theming', as: :docs_theming
    get 'dark_mode', to: 'docs#dark_mode', as: :docs_dark_mode
    get 'customizing_components', to: 'docs#customizing_components', as: :docs_customizing_components

    # INSTALLATION
    get 'installation/rails_bundler', to: 'docs#installation_rails_bundler', as: :docs_installation_rails_bundler
    get 'installation/rails_importmaps', to: 'docs#installation_rails_importmaps', as: :docs_installation_rails_importmaps
    
    # COMPONENTS
    get 'accordion', to: 'docs#accordion', as: :docs_accordion
    get 'alert', to: 'docs#alert_component', as: :docs_alert # alert is a reserved word for controller action
    get 'alert_dialog', to: 'docs#alert_dialog', as: :docs_alert_dialog
    get 'aspect_ratio', to: 'docs#aspect_ratio', as: :docs_aspect_ratio
    get 'avatar', to: 'docs#avatar', as: :docs_avatar
    get 'badge', to: 'docs#badge', as: :docs_badge
    get 'button', to: 'docs#button', as: :docs_button
    get 'card', to: 'docs#card', as: :docs_card
    get 'calendar', to: 'docs#calendar', as: :docs_calendar
    get 'checkbox', to: 'docs#checkbox', as: :docs_checkbox
    get 'codeblock', to: 'docs#codeblock', as: :docs_codeblock
    get 'collapsible', to: 'docs#collapsible', as: :docs_collapsible
    get 'command', to: 'docs#command', as: :docs_command
    get 'context_menu', to: 'docs#context_menu', as: :docs_context_menu
    get 'date_picker', to: 'docs#date_picker', as: :docs_date_picker
    get 'dropdown_menu', to: 'docs#dropdown_menu', as: :docs_dropdown_menu
    get 'dialog', to: 'docs#dialog', as: :docs_dialog
    get 'hover_card', to: 'docs#hover_card', as: :docs_hover_card
    get 'input', to: 'docs#input', as: :docs_input
    get 'link', to: 'docs#link', as: :docs_link
    get 'popover', to: 'docs#popover', as: :docs_popover
    get 'sheet', to: 'docs#sheet', as: :docs_sheet
    get 'shortcut_key', to: 'docs#shortcut_key', as: :docs_shortcut_key
    get 'table', to: 'docs#table', as: :docs_table
    get 'tabs', to: 'docs#tabs', as: :docs_tabs
    get 'theme_toggle', to: 'docs#theme_toggle', as: :docs_theme_toggle
    get 'tooltip', to: 'docs#tooltip', as: :docs_tooltip
    get 'typography', to: 'docs#typography', as: :docs_typography
  end
  root "pages#home"
end
