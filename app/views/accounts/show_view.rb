# frozen_string_literal: true

class Accounts::ShowView < ApplicationView
  def template
    render Shared::GridPattern.new
    div(class: 'container max-w-2xl mx-auto px-4 pb-24 space-y-6') do
      div(class: "space-y-4 py-16 md:py-24 md:pb-20 max-w-lg mx-auto") do
        render PhlexUI::Typography::H1.new(class: 'text-center') { "Account" }
      end
    end
  end
end
