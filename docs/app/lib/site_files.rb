# frozen_string_literal: true

require "cgi"

class SiteFiles
  DEFAULT_BASE_URL = "https://rubyui.com"

  CORE_DOCS = [
    {
      title: "Introduction",
      path: "/docs/introduction",
      description: "Overview of RubyUI, its Phlex, Tailwind CSS, and Stimulus foundations, and its design goals.",
      priority: 0.9,
      changefreq: "weekly"
    },
    {
      title: "Installation",
      path: "/docs/installation",
      description: "Entry point for choosing a Rails installation path.",
      priority: 0.9,
      changefreq: "weekly"
    },
    {
      title: "Rails - JS Bundler",
      path: "/docs/installation/rails_bundler",
      description: "Install RubyUI in a Rails app that uses JavaScript bundling.",
      priority: 0.8,
      changefreq: "monthly"
    },
    {
      title: "Rails - Importmaps",
      path: "/docs/installation/rails_importmaps",
      description: "Install RubyUI in a Rails app that uses import maps.",
      priority: 0.8,
      changefreq: "monthly"
    },
    {
      title: "Theming",
      path: "/docs/theming",
      description: "Use CSS variables and shadcn/ui-compatible theme tokens with RubyUI.",
      priority: 0.8,
      changefreq: "monthly"
    },
    {
      title: "Dark mode",
      path: "/docs/dark_mode",
      description: "Configure dark mode with the Tailwind CSS class strategy and RubyUI theme toggle.",
      priority: 0.8,
      changefreq: "monthly"
    },
    {
      title: "Customizing components",
      path: "/docs/customizing_components",
      description: "Adapt generated RubyUI components when theme-level customization is not enough.",
      priority: 0.8,
      changefreq: "monthly"
    },
    {
      title: "Components",
      path: "/docs/components",
      description: "Catalog of available RubyUI components.",
      priority: 0.9,
      changefreq: "weekly"
    },
    {
      title: "Changelog",
      path: "/docs/changelog",
      description: "Recent RubyUI component and documentation changes.",
      priority: 0.6,
      changefreq: "weekly"
    },
    {
      title: "MCP Server",
      path: "/docs/mcp",
      description: "Connect AI agents to Ruby UI components, source, examples, and install commands via the Model Context Protocol.",
      priority: 0.8,
      changefreq: "monthly"
    }
  ].freeze

  COMPONENT_DOCS = [
    {title: "Accordion", path: "/docs/accordion", description: "Vertically stacked interactive headings that reveal sections of content."},
    {title: "Alert", path: "/docs/alert", description: "Callout component for drawing attention to contextual information."},
    {title: "Alert Dialog", path: "/docs/alert_dialog", description: "Modal dialog for interruptive content that expects a response."},
    {title: "Aspect Ratio", path: "/docs/aspect_ratio", description: "Container for displaying content within a desired ratio."},
    {title: "Avatar", path: "/docs/avatar", description: "Image and fallback primitives for representing a user."},
    {title: "Badge", path: "/docs/badge", description: "Small status or label element."},
    {title: "Breadcrumb", path: "/docs/breadcrumb", description: "Navigation trail showing the current location in a hierarchy."},
    {title: "Bubble", path: "/docs/bubble", description: "Chat bubble surface with variants, alignment, grouping, and reactions."},
    {title: "Button", path: "/docs/button", description: "Button component and button-like variants."},
    {title: "Calendar", path: "/docs/calendar", description: "Date field component for entering and editing dates."},
    {title: "Card", path: "/docs/card", description: "Content container with header, content, and footer primitives."},
    {title: "Carousel", path: "/docs/carousel", description: "Embla-powered carousel with motion and swipe interactions."},
    {title: "Checkbox", path: "/docs/checkbox", description: "Control for toggling between checked and unchecked states."},
    {title: "Checkbox Group", path: "/docs/checkbox_group", description: "Grouped checkbox controls."},
    {title: "Clipboard", path: "/docs/clipboard", description: "Control for copying content to the clipboard."},
    {title: "Codeblock", path: "/docs/codeblock", description: "Highlighted code display component."},
    {title: "Collapsible", path: "/docs/collapsible", description: "Interactive component for expanding and collapsing a panel."},
    {title: "Combobox", path: "/docs/combobox", description: "Autocomplete input and command palette with suggestions."},
    {title: "Command", path: "/docs/command", description: "Composable command menu for Phlex applications."},
    {title: "Context Menu", path: "/docs/context_menu", description: "Right-click menu for contextual actions."},
    {title: "Data Table", path: "/docs/data_table", description: "Data table primitives for search, sorting, pagination, visibility, and bulk actions."},
    {title: "Date Picker", path: "/docs/date_picker", description: "Date picker component with input."},
    {title: "Dialog", path: "/docs/dialog", description: "Modal window that renders background content inert."},
    {title: "Dropdown Menu", path: "/docs/dropdown_menu", description: "Button-triggered menu for actions or functions."},
    {title: "Empty", path: "/docs/empty", description: "Empty state for when there is no data or content."},
    {title: "Form", path: "/docs/form", description: "Form fields with built-in client-side validations."},
    {title: "Hover Card", path: "/docs/hover_card", description: "Preview content exposed behind a link or trigger."},
    {title: "Input", path: "/docs/input", description: "Styled input field primitive."},
    {title: "Link", path: "/docs/link", description: "Link component with button-like and underline variants."},
    {title: "Masked Input", path: "/docs/masked_input", description: "Form input with an applied mask."},
    {title: "Message", path: "/docs/message", description: "Chat message layout pairing an avatar with bubbles, headers, and footers."},
    {title: "Message Scroller", path: "/docs/message_scroller", description: "Chat scroll container that anchors turns, follows streamed output, and jumps to the latest message."},
    {title: "Pagination", path: "/docs/pagination", description: "Page navigation with next and previous links."},
    {title: "Popover", path: "/docs/popover", description: "Triggered rich content panel."},
    {title: "Progress", path: "/docs/progress", description: "Progress bar for task completion state."},
    {title: "Radio Button", path: "/docs/radio_button", description: "Single-selection control for option lists."},
    {title: "Native Select", path: "/docs/native_select", description: "Styled native HTML select element."},
    {title: "Select", path: "/docs/select", description: "Button-triggered option picker."},
    {title: "Separator", path: "/docs/separator", description: "Visual or semantic divider."},
    {title: "Sheet", path: "/docs/sheet", description: "Side panel for content that complements the main screen."},
    {title: "Shortcut Key", path: "/docs/shortcut_key", description: "Keyboard shortcut display component."},
    {title: "Sidebar", path: "/docs/sidebar", description: "Composable, themeable sidebar component."},
    {title: "Skeleton", path: "/docs/skeleton", description: "Placeholder for loading states."},
    {title: "Switch", path: "/docs/switch", description: "Toggle control for binary settings."},
    {title: "Table", path: "/docs/table", description: "Responsive table component."},
    {title: "Tabs", path: "/docs/tabs", description: "Layered tab panels displayed one at a time."},
    {title: "Textarea", path: "/docs/textarea", description: "Styled multiline text input."},
    {title: "Theme Toggle", path: "/docs/theme_toggle", description: "Toggle control for switching between light and dark themes."},
    {title: "Toggle", path: "/docs/toggle", description: "Two-state button that can be either on or off."},
    {title: "Toggle Group", path: "/docs/toggle_group", description: "Group of two-state toggle buttons."},
    {title: "Tooltip", path: "/docs/tooltip", description: "Popup information shown on keyboard focus or hover."},
    {title: "Typography", path: "/docs/typography", description: "Text primitives and sensible typography defaults."}
  ].freeze

  EXAMPLE_DOCS = [
    {
      title: "Data Table Demo",
      path: "/docs/data_table_demo",
      description: "Interactive data table example using RubyUI table primitives.",
      priority: 0.5,
      changefreq: "monthly"
    },
    {
      title: "Sidebar Example",
      path: "/docs/sidebar/example",
      description: "Standalone sidebar example page.",
      priority: 0.5,
      changefreq: "monthly"
    },
    {
      title: "Sidebar Inset Example",
      path: "/docs/sidebar/inset",
      description: "Sidebar inset layout example page.",
      priority: 0.5,
      changefreq: "monthly"
    }
  ].freeze

  SITE_PAGES = [
    {
      title: "RubyUI",
      path: "/",
      description: "Home page for RubyUI, a UI component library for Ruby developers.",
      priority: 1.0,
      changefreq: "weekly"
    },
    {
      title: "Themes",
      path: "/themes/default",
      description: "Theme preview and CSS variable copy tool.",
      priority: 0.7,
      changefreq: "monthly"
    }
  ].freeze

  PROJECT_RESOURCES = [
    {
      title: "GitHub repository",
      url: "https://github.com/ruby-ui/ruby_ui",
      description: "Source code for the RubyUI gem and documentation app."
    },
    {
      title: "RubyGems package",
      url: "https://rubygems.org/gems/ruby_ui",
      description: "Published ruby_ui gem package."
    }
  ].freeze

  def initialize(base_url: DEFAULT_BASE_URL)
    @base_url = base_url.delete_suffix("/")
  end

  def llms_txt
    lines = [
      "# RubyUI",
      "",
      "> Beautifully designed, accessible, customizable UI components for Ruby and Rails apps, built with Phlex, Tailwind CSS, and Stimulus.",
      "",
      "RubyUI is a development-time gem for generating or copying reusable Ruby UI components into an application. The generated code belongs to the host app and can be customized directly. Documentation pages usually contain live examples, code snippets, setup instructions, and source file references.",
      "",
      "Use the core docs first for installation, theming, dark mode, and customization context. Use component docs when you need exact component APIs, examples, and related source files. Use llms-full.txt when a single expanded reference is more useful than a curated link map.",
      "",
      "## Core docs",
      "",
      *markdown_links(CORE_DOCS),
      "",
      "## Component docs",
      "",
      *markdown_links(COMPONENT_DOCS),
      "",
      "## Examples",
      "",
      *markdown_links(EXAMPLE_DOCS),
      "",
      "## Project resources",
      "",
      *resource_links,
      "",
      "## Optional",
      "",
      "- [Full LLM reference](#{absolute_url("/llms-full.txt")}): Expanded single-file overview of RubyUI installation, conventions, and component catalog.",
      "- [Sitemap](#{absolute_url("/sitemap.xml")}): XML sitemap for public RubyUI pages."
    ]

    "#{lines.join("\n")}\n"
  end

  def llms_full_txt
    lines = [
      "# RubyUI Full LLM Reference",
      "",
      "> RubyUI provides accessible, customizable UI components for Ruby and Rails applications. It is built on Phlex for Ruby-rendered views, Tailwind CSS for styling, and Stimulus for small client-side behaviors.",
      "",
      "This file expands the curated /llms.txt map into a compact reference that can be loaded as one document. It is intentionally prose-heavy and link-rich so language models can answer common questions without crawling the whole documentation site.",
      "",
      "## Product model",
      "",
      "- RubyUI is distributed as the `ruby_ui` gem.",
      "- RubyUI is intended primarily for development-time generation and copy-paste workflows.",
      "- Components are Ruby classes that render HTML through Phlex.",
      "- Styling uses Tailwind CSS utilities and CSS variables.",
      "- Interactive components use lightweight Stimulus controllers.",
      "- The design language is inspired by shadcn/ui and keeps theme tokens compatible with shadcn/ui-style CSS variables.",
      "",
      "## Common installation workflow",
      "",
      "1. Add the gem to a Rails application with `bundle add ruby_ui --group development --require false`.",
      "2. Run `bin/rails g ruby_ui:install` to install RubyUI support files.",
      "3. Generate a component with `bin/rails g ruby_ui:component ComponentName`, for example `bin/rails g ruby_ui:component Button`.",
      "4. Customize generated Ruby, Tailwind classes, and Stimulus controllers inside the host app as needed.",
      "",
      "## Important implementation notes",
      "",
      "- Treat generated components as application code, not a sealed runtime dependency.",
      "- Prefer the docs installation path matching the Rails JavaScript setup: JS bundler or import maps.",
      "- Use the theming docs for CSS variable setup before making broad visual changes.",
      "- Use the dark mode docs when adding or moving `ThemeToggle`.",
      "- Component documentation pages usually end with setup tabs and a table of component files.",
      "",
      "## Core documentation",
      "",
      *expanded_pages(CORE_DOCS),
      "",
      "## Component catalog",
      "",
      *expanded_pages(COMPONENT_DOCS),
      "",
      "## Examples and demos",
      "",
      *expanded_pages(EXAMPLE_DOCS),
      "",
      "## Themes",
      "",
      "- [Themes](#{absolute_url("/themes/default")}): Preview and copy hand-picked themes that are compatible with RubyUI and shadcn/ui token conventions.",
      "",
      "## External resources",
      "",
      *resource_links,
      "",
      "## Companion machine-readable files",
      "",
      "- [llms.txt](#{absolute_url("/llms.txt")}): Curated LLM link map.",
      "- [sitemap.xml](#{absolute_url("/sitemap.xml")}): XML sitemap for public pages."
    ]

    "#{lines.join("\n")}\n"
  end

  def sitemap_xml
    lines = [
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
      "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
    ]

    sitemap_pages.each do |page|
      lines << "  <url>"
      lines << "    <loc>#{xml_escape(absolute_url(page.fetch(:path)))}</loc>"
      lines << "    <changefreq>#{xml_escape(page.fetch(:changefreq))}</changefreq>"
      lines << "    <priority>#{format("%.1f", page.fetch(:priority))}</priority>"
      lines << "  </url>"
    end

    lines << "</urlset>"
    "#{lines.join("\n")}\n"
  end

  private

  def sitemap_pages
    SITE_PAGES + CORE_DOCS + component_sitemap_pages + EXAMPLE_DOCS
  end

  def component_sitemap_pages
    COMPONENT_DOCS.map do |page|
      page.merge(priority: 0.7, changefreq: "monthly")
    end
  end

  def markdown_links(pages)
    pages.map do |page|
      "- [#{page.fetch(:title)}](#{absolute_url(page.fetch(:path))}): #{page.fetch(:description)}"
    end
  end

  def expanded_pages(pages)
    pages.flat_map do |page|
      [
        "### #{page.fetch(:title)}",
        "",
        "- URL: #{absolute_url(page.fetch(:path))}",
        "- Summary: #{page.fetch(:description)}",
        ""
      ]
    end
  end

  def resource_links
    PROJECT_RESOURCES.map do |resource|
      "- [#{resource.fetch(:title)}](#{resource.fetch(:url)}): #{resource.fetch(:description)}"
    end
  end

  def xml_escape(value)
    CGI.escapeHTML(value.to_s)
  end

  def absolute_url(path)
    return "#{@base_url}/" if path == "/"

    "#{@base_url}#{path}"
  end
end
