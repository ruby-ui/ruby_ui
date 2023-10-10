# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def template
    div(class: 'max-w-lg mx-auto px-4 sm:px-6 lg:px-8 py-10') do
      h1(class: 'text-4xl font-extrabold text-gray-900 sm:text-5xl') { "Phlex Components Library" }
    end
  end
end
