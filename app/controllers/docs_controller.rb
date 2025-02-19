# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { DocsLayout }

  # GETTING STARTED
  def introduction
    render Views::Docs::GettingStarted::IntroductionView.new
  end

  def installation
    render Views::Docs::GettingStarted::InstallationView.new
  end

  def theming
    render Views::Docs::GettingStarted::ThemingView.new
  end

  def dark_mode
    render Views::Docs::GettingStarted::DarkModeView.new
  end

  def customizing_components
    render Views::Docs::GettingStarted::CustomizingComponentsView.new
  end

  # INSTALLATION
  def installation_rails_bundler
    render Views::Docs::Installation::RailsBundlerView.new
  end

  def installation_rails_importmaps
    render Views::Docs::Installation::RailsImportmapsView.new
  end

  # COMPONENTS
  def accordion
    render Views::Docs::AccordionView.new
  end

  def alert_component # alert is a reserved word
    render Views::Docs::AlertView.new
  end

  def alert_dialog
    render Views::Docs::AlertDialogView.new
  end

  def aspect_ratio
    render Views::Docs::AspectRatioView.new
  end

  def avatar
    render Views::Docs::AvatarView.new
  end

  def badge
    render Views::Docs::BadgeView.new
  end

  def breadcrumb
    render Views::Docs::BreadcrumbView.new
  end

  def button
    render Views::Docs::ButtonView.new
  end

  def card
    render Views::Docs::CardView.new
  end

  def calendar
    render Views::Docs::CalendarView.new
  end

  def chart
    render Views::Docs::ChartView.new
  end

  def checkbox
    render Views::Docs::CheckboxView.new
  end

  def checkbox_group
    render Views::Docs::CheckboxGroupView.new
  end

  def clipboard
    render Views::Docs::ClipboardView.new
  end

  def codeblock
    render Views::Docs::CodeblockView.new
  end

  def collapsible
    render Views::Docs::CollapsibleView.new
  end

  def combobox
    render Views::Docs::ComboboxView.new
  end

  def command
    render Views::Docs::CommandView.new
  end

  def context_menu
    render Views::Docs::ContextMenuView.new
  end

  def date_picker
    render Views::Docs::DatePickerView.new
  end

  def dialog
    render Views::Docs::DialogView.new
  end

  def dropdown_menu
    render Views::Docs::DropdownMenuView.new
  end

  def form
    render Views::Docs::FormView.new
  end

  def hover_card
    render Views::Docs::HoverCardView.new
  end

  def input
    render Views::Docs::InputView.new
  end

  def link
    render Views::Docs::LinkView.new
  end

  def masked_input
    render Views::Docs::MaskedInputView.new
  end

  def pagination
    render Views::Docs::PaginationView.new
  end

  def popover
    render Views::Docs::PopoverView.new
  end

  def progress
    render Views::Docs::ProgressView.new
  end

  def radio_button
    render Views::Docs::RadioButtonView.new
  end

  def select
    render Views::Docs::SelectView.new
  end

  def sheet
    render Views::Docs::SheetView.new
  end

  def shortcut_key
    render Views::Docs::ShortcutKeyView.new
  end

  def skeleton
    render Views::Docs::SkeletonView.new
  end

  def switch
    render Views::Docs::SwitchView.new
  end

  def table
    render Views::Docs::TableView.new
  end

  def tabs
    render Views::Docs::TabsView.new
  end

  def textarea
    render Views::Docs::TextareaView.new
  end

  def theme_toggle
    render Views::Docs::ThemeToggleView.new
  end

  def tooltip
    render Views::Docs::TooltipView.new
  end

  def typography
    render Views::Docs::TypographyView.new
  end
end
