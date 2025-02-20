# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { Views::Layouts::DocsLayout }

  # GETTING STARTED
  def introduction
    render Views::Docs::GettingStarted::Introduction.new
  end

  def installation
    render Views::Docs::GettingStarted::Installation.new
  end

  def theming
    render Views::Docs::GettingStarted::Theming.new
  end

  def dark_mode
    render Views::Docs::GettingStarted::DarkMode.new
  end

  def customizing_components
    render Views::Docs::GettingStarted::CustomizingComponents.new
  end

  # INSTALLATION
  def installation_rails_bundler
    render Views::Docs::Installation::RailsBundler.new
  end

  def installation_rails_importmaps
    render Views::Docs::Installation::RailsImportmaps.new
  end

  # COMPONENTS
  def accordion
    render Views::Docs::Accordion.new
  end

  def alert_component # alert is a reserved word
    render Views::Docs::Alert.new
  end

  def alert_dialog
    render Views::Docs::AlertDialog.new
  end

  def aspect_ratio
    render Views::Docs::AspectRatio.new
  end

  def avatar
    render Views::Docs::Avatar.new
  end

  def badge
    render Views::Docs::Badge.new
  end

  def breadcrumb
    render Views::Docs::Breadcrumb.new
  end

  def button
    render Views::Docs::Button.new
  end

  def card
    render Views::Docs::Card.new
  end

  def calendar
    render Views::Docs::Calendar.new
  end

  def chart
    render Views::Docs::Chart.new
  end

  def checkbox
    render Views::Docs::Checkbox.new
  end

  def checkbox_group
    render Views::Docs::CheckboxGroup.new
  end

  def clipboard
    render Views::Docs::Clipboard.new
  end

  def codeblock
    render Views::Docs::Codeblock.new
  end

  def collapsible
    render Views::Docs::Collapsible.new
  end

  def combobox
    render Views::Docs::Combobox.new
  end

  def command
    render Views::Docs::Command.new
  end

  def context_menu
    render Views::Docs::ContextMenu.new
  end

  def date_picker
    render Views::Docs::DatePicker.new
  end

  def dialog
    render Views::Docs::Dialog.new
  end

  def dropdown_menu
    render Views::Docs::DropdownMenu.new
  end

  def form
    render Views::Docs::Form.new
  end

  def hover_card
    render Views::Docs::HoverCard.new
  end

  def input
    render Views::Docs::Input.new
  end

  def link
    render Views::Docs::Link.new
  end

  def masked_input
    render Views::Docs::MaskedInput.new
  end

  def pagination
    render Views::Docs::Pagination.new
  end

  def popover
    render Views::Docs::Popover.new
  end

  def progress
    render Views::Docs::Progress.new
  end

  def radio_button
    render Views::Docs::RadioButton.new
  end

  def select
    render Views::Docs::Select.new
  end

  def sheet
    render Views::Docs::Sheet.new
  end

  def shortcut_key
    render Views::Docs::ShortcutKey.new
  end

  def skeleton
    render Views::Docs::Skeleton.new
  end

  def switch
    render Views::Docs::Switch.new
  end

  def table
    render Views::Docs::Table.new
  end

  def tabs
    render Views::Docs::Tabs.new
  end

  def textarea
    render Views::Docs::Textarea.new
  end

  def theme_toggle
    render Views::Docs::ThemeToggle.new
  end

  def tooltip
    render Views::Docs::Tooltip.new
  end

  def typography
    render Views::Docs::Typography.new
  end
end
