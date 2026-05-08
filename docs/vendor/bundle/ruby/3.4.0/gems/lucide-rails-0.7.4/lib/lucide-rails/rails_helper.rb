# frozen_string_literal: true

module LucideRails
  module RailsHelper
    def lucide_icon(named, **options)
      options = options.with_indifferent_access
      size = options.delete(:size)
      options = options.merge width: size, height: size if size

      content_tag(:svg,
                  IconProvider.icon(named).html_safe,
                  LucideRails.default_options.merge(**options))
    end
  end
end
