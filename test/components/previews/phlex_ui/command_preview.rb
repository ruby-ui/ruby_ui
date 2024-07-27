# frozen_string_literal: true

module PhlexUi
  class CommandPreview < Lookbook::Preview
    # Default Command
    # ---------------
    def default
      render(TestView.new) do
        CommandDialog do
          CommandDialogTrigger do
            Button(variant: "outline", class: "w-56 pr-2 pl-3 justify-between") do
              div(class: "flex items-center space-x-1") do
                plain(helpers.lucide_icon("search", class: "w-4 h-4 mr-1.5"))
                span(class: "text-muted-foreground font-normal") { plain("Search") }
              end
            end
          end

          CommandDialogContent do
            Command do
              CommandInput(placeholder: "Type a command or search..")
              CommandEmpty { "No results found" }
              CommandList do
                CommandGroup(title: "Components") do
                  [
                    {name: "Accordion", path: "#"},
                    {name: "Alert", path: "#"},
                    {name: "Alert Dialog", path: "#"},
                    {name: "Aspect Ratio", path: "#"},
                    {name: "Avatar", path: "#"},
                    {name: "Badge", path: "#"}
                  ].each do |component|
                    CommandItem(value: component[:name], href: component[:path]) do
                      plain(helpers.lucide_icon("circle-arrow-right", class: "w-4 h-4"))
                      plain(component[:name])
                    end
                  end
                end

                CommandGroup(title: "Settings") do
                  [
                    {name: "Profile", path: "#"},
                    {name: "Mail", path: "#"},
                    {name: "Settings", path: "#"}
                  ].each do |setting|
                    CommandItem(value: setting[:name], href: setting[:path]) do
                      plain(helpers.lucide_icon("circle-arrow-right", class: "w-4 h-4"))
                      plain(setting[:name])
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
