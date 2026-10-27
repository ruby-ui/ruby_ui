# frozen_string_literal: true

# Added by the shadcn audit (audit/preview_overlay) to an archived checkout.
# GET /__audit/:component?theme=light|dark renders one audit fixture with the
# docs app's stylesheet and JS, without the site chrome.
class ShadcnAuditFixturesController < ActionController::Base
  FIXTURES_DIR = Rails.root.join("app/views/shadcn_audit_fixtures")
  THEMES = %w[light dark].freeze

  layout false

  def show
    component = params[:component].to_s
    file = FIXTURES_DIR.join("#{component}.rb")
    raise ActionController::RoutingError, "no audit fixture #{component.inspect}" unless component.match?(/\A[a-z_]+\z/) && file.file?

    # load, not require: picks up re-copied fixtures and reloaded RubyUI code.
    load file.to_s
    fixture = ShadcnAuditFixtures.const_get(component.camelize, false)
    theme = THEMES.include?(params[:theme]) ? params[:theme] : "light"
    render Page.new(fixture.new, component: component, theme: theme)
  end

  class Page < Phlex::HTML
    include Phlex::Rails::Layout

    def initialize(fixture, component:, theme:)
      @fixture = fixture
      @component = component
      @theme = theme
    end

    def view_template
      doctype
      html(lang: "en", class: (@theme == "dark") ? "dark" : nil) do
        head do
          title { "shadcn audit fixture" }
          meta name: "viewport", content: "width=device-width,initial-scale=1"
          csp_meta_tag
          csrf_meta_tags
          stylesheet_link_tag "application"
          javascript_include_tag "application", type: "module"
        end
        # Same wrapper as the shadcn sandbox (audit/sandbox_template/src/main.tsx).
        body { div(data: {audit_fixture: @component}) { render @fixture } }
      end
    end
  end
end
