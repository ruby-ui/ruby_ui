# frozen_string_literal: true

class AlertDialog < ApplicationComponent
  def initialize(open: false)
    @open = open
  end
  
  def template(&)
    div(data: { controller: 'alert-dialog', alert_dialog_open_value: @open }, class: 'inline-block', &)
  end
end
