# frozen_string_literal: true

module PhlexUi
  class ClipboardPreview < Lookbook::Preview
    # Default Clipboard
    # ---------------
    def default
      render(TestView.new) do
        Clipboard(success: "Copiado!", error: "Falha ao copiar!", class: "relative") do
          ClipboardSource(class: "hidden") { span { "Nascer herdeiro!!!" } }

          ClipboardTrigger do
            Link(href: "#", class: "gap-1") do
              TypographyP(size: :small, class: "text-primary") { "Copiar segredo do sucesso!!!" }
            end
          end
        end
      end
    end
  end
end
