# frozen_string_literal: true

class Docs::TableView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Table" }
        render Typography::P.new { "A responsive table component." }
      end

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          render Table.new do
            render TableCaption.new { "Employees at Acme inc." }
            render TableHeader.new do
              render TableRow.new do
                render TableHead.new { "Name" }
                render TableHead.new { "Title" }
                render TableHead.new { "Status" }
                render TableHead.new { "Role" }
              end
            end
            render TableBody.new do
              people.each do |person|
                render TableRow.new do
                  render TableCell.new(class: 'font-medium') { person[:name] }
                  render TableCell.new { person[:title] }
                  render TableCell.new { render_status_badge(person[:status]) }
                  render TableCell.new { person[:role] }
                end
              end
            end
          end
        RUBY
      end
    end
  end

  def people
    [
      { name: "Jane Cooper", title: "Regional Paradigm Technician", status: "Active", role: "Admin" },
      { name: "Cody Fisher", title: "Product Directives Officer", status: "Inactive", role: "Owner" },
      { name: "Esther Howard", title: "Forward Response Developer", status: "Pending", role: "Member" },
      { name: "Jenny Wilson", title: "Central Security Manager", status: "Active", role: "Admin" },
    ]
  end

  def render_status_badge(status)
    case status.downcase
    when "active"
      render Badge.new(variant: :primary) { status }
    when "inactive"
      render Badge.new(variant: :destructive) { status }
    when "pending"
      render Badge.new(variant: :secondary) { status }
    end
  end
end
