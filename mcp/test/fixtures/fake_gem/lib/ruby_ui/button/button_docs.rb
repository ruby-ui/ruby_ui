class Views::Docs::Button
  def view_template
    render Docs::Header.new(title: "Button", description: "A clickable button.")

    Heading(level: 2) { "Usage" }

    render Docs::VisualCodeExample.new(title: "Example", context: self) do
      <<~RUBY
        Button { "Button" }
      RUBY
    end

    render Docs::VisualCodeExample.new(title: "Primary", context: self) do
      <<~RUBY
        Button(variant: :primary) { "Primary" }
      RUBY
    end
  end
end
