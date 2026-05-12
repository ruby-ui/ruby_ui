# frozen_string_literal: true

module RubyUI
  class ToastDocs < Phlex::HTML
    def view_template
      div(class: "space-y-4") do
        h2 { "Toast" }
        p { "Hotwire-native sonner port. Mount once; trigger via Turbo Stream or window.RubyUI.toast." }
      end
    end
  end
end
