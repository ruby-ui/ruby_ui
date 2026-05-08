# frozen_string_literal: true

module LucideRails
  class Railtie < Rails::Railtie
    initializer "lucide-rails.helper" do
      ActiveSupport.on_load(:action_view) do
        include LucideRails::RailsHelper
      end
    end
  end
end
