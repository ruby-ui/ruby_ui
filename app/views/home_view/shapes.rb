# frozen_string_literal: true

class HomeView::Shapes < ApplicationComponent
  def initialize(size: :md, **attributes)
    @attributes = attributes
    @circle_sizes = {
      xs: "w-8 h-8",
      sm: "w-12 h-12",
      md: "w-16 h-16",
      lg: "w-24 h-24",
      xl: "w-32 h-32"
    }

    @square_sizes = {
      xs: "w-16 h-16 rounde-md",
      sm: "w-24 h-24 rounded-md",
      md: "w-32 h-32 rounded-lg",
      lg: "w-48 h-48 rounded-lg",
      xl: "w-64 h-64 rounded-xl"
    }

    @size = size
    @colors = %w[sky violet pink amber lime]
    @color = @attributes.delete(:color) || @colors.sample
  end

  def view_template
    # Create one square and one circle of different colors
    # The square will be on a rotation of 15deg
    # the circle will be a solid color
    # The shapes will be slightly overlapping
    div(**@attributes) do
      div(class: "relative") do
        circle
        square
      end
    end
  end

  def square
    color_classes = {
      sky: "bg-sky-500/10 backdrop-blur-3xl ring-1 ring-sky-600/20 saturate-150",
      violet: "bg-violet-500/10 backdrop-blur-3xl ring-1 ring-violet-600/20 saturate-150",
      pink: "bg-pink-500/10 backdrop-blur-3xl ring-1 ring-pink-600/20 saturate-150",
      amber: "bg-amber-500/10 backdrop-blur-3xl ring-1 ring-amber-600/20 saturate-150",
      lime: "bg-lime-500/10 backdrop-blur-3xl ring-1 ring-lime-600/20 saturate-150"
    }

    sample_color = color_classes[@color.to_sym]

    div(class: "#{@square_sizes[@size]} #{sample_color} -rotate-12")
  end

  def circle
    color_classes = {
      sky: "bg-sky-400",
      violet: "bg-violet-400",
      pink: "bg-pink-400",
      amber: "bg-amber-400",
      lime: "bg-lime-400"
    }

    sample_color = color_classes[@color.to_sym]

    div(class: "#{@circle_sizes[@size]} #{sample_color} rounded-full absolute top-0 left-0 transform -translate-x-1/2 -translate-y-1/2")
  end
end
