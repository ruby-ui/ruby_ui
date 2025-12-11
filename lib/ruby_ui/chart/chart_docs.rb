# frozen_string_literal: true

class Views::Docs::Chart < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Chart", description: "Displays information in a visual way.")

      Heading(level: 2) { "Introduction" }

      Text do
        plain "RubyUI uses "
        InlineLink(href: "https://www.chartjs.org/") { "Chart.js" }
        plain " to render charts. Chart.js is a free open-source JavaScript library for data visualization, which supports 8 chart types: bar, line, area, pie, bubble, radar, polar, and scatter. If you're unfamiliar with Chart.js. We recommend the "
        InlineLink(href: "https://www.chartjs.org/docs/latest/getting-started/") { "Getting Started guide" }
        plain ". "
      end

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Bar Chart", context: self) do
        <<~RUBY
          options = {
            type: 'bar',
            data: {
              labels: ['Phlex', 'VC', 'ERB'],
              datasets: [{
                label: 'render time (ms)',
                data: [100, 520, 1200],
              }]
            },
            options: {
              indexAxis: 'y',
              scales: {
                y: {
                  beginAtZero: true
                }
              },
            },
          }

          Chart(options: options)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Line Graph", context: self) do
        <<~RUBY
          options = {
            type: 'line',
            data: {
              labels: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
              datasets: [{
                label: 'Github Stars',
                data: [40, 30, 79, 140, 290, 550],
              }]
            },
            options: {
              scales: {
                y: {
                  beginAtZero: true
                }
              },
              plugins: {
                legend: {
                  display: false
                }
              }
            },
          }

          Chart(options: options)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Pie Chart", description: "Setting custom background color", context: self) do
        <<~RUBY
          options = {
            type: 'pie',
            data: {
              labels: [
                'Red',
                'Blue',
                'Yellow'
              ],
              datasets: [{
                label: 'My First Dataset',
                data: [300, 50, 100],
                backgroundColor: [
                  'rgb(255, 99, 132)',
                  'rgb(54, 162, 235)',
                  'rgb(255, 205, 86)'
                ],
                hoverOffset: 4
              }]
            },
          }

          Chart(options: options)
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: "Chart")

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      ::Docs::ComponentStruct.new(name: "ChartController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/chart_controller.js", built_using: :stimulus),
      ::Docs::ComponentStruct.new(name: "Chart", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/chart.rb", built_using: :phlex)
    ]
  end
end
