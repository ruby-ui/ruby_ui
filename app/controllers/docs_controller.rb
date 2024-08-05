# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { DocsLayout }

  # GETTING STARTED
  def introduction
    render Docs::GettingStarted::IntroductionView.new
  end

  def installation
    render Docs::GettingStarted::InstallationView.new
  end

  def theming
    render Docs::GettingStarted::ThemingView.new
  end

  def dark_mode
    render Docs::GettingStarted::DarkModeView.new
  end

  def customizing_components
    render Docs::GettingStarted::CustomizingComponentsView.new
  end

  # INSTALLATION
  def installation_rails_bundler
    render Docs::Installation::RailsBundlerView.new
  end

  def installation_rails_importmaps
    render Docs::Installation::RailsImportmapsView.new
  end

  # COMPONENTS
  def accordion
    render Docs::AccordionView.new
  end

  def alert_component # alert is a reserved word
    render Docs::AlertView.new
  end

  def alert_dialog
    render Docs::AlertDialogView.new
  end

  def aspect_ratio
    render Docs::AspectRatioView.new
  end

  def avatar
    render Docs::AvatarView.new
  end

  def badge
    render Docs::BadgeView.new
  end

  def button
    render Docs::ButtonView.new
  end

  def card
    render Docs::CardView.new
  end

  def calendar
    render Docs::CalendarView.new
  end

  def chart
    render Docs::ChartView.new
  end

  def checkbox
    render Docs::CheckboxView.new
  end

  def codeblock
    render Docs::CodeblockView.new
  end

  def collapsible
    render Docs::CollapsibleView.new
  end

  def combobox
    render Docs::ComboboxView.new
  end

  def command
    render Docs::CommandView.new
  end

  def context_menu
    render Docs::ContextMenuView.new
  end

  def date_picker
    render Docs::DatePickerView.new
  end

  def dialog
    render Docs::DialogView.new
  end

  def dropdown_menu
    render Docs::DropdownMenuView.new
  end

  def hover_card
    render Docs::HoverCardView.new
  end

  def input
    render Docs::InputView.new
  end

  def link
    render Docs::LinkView.new
  end

  def pagination
    render Docs::PaginationView.new
  end

  def popover
    render Docs::PopoverView.new
  end

  def select
    render Docs::SelectView.new
  end

  def sheet
    render Docs::SheetView.new
  end

  def shortcut_key
    render Docs::ShortcutKeyView.new
  end

  def table
    render Docs::TableView.new
  end

  def tabs
    render Docs::TabsView.new
  end

  def theme_toggle
    render Docs::ThemeToggleView.new
  end

  def tooltip
    render Docs::TooltipView.new
  end

  def typography
    render Docs::TypographyView.new
  end
end
