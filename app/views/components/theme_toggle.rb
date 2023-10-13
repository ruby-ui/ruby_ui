# frozen_string_literal: true

class ThemeToggle < ApplicationComponent
  def template(&)
    div(data: { controller: 'toggle-theme' }, &)
  end

  def light_mode(&)
    div(class: 'dark:hidden', data: { action: 'click->toggle-theme#setDarkTheme' }, &)
  end

  def dark_mode(&)
    div(class: 'hidden dark:inline-block', data: { action: 'click->toggle-theme#setLightTheme' }, &)
  end
end
