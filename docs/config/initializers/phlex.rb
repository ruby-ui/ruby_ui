# frozen_string_literal: true

module Views
end

module Components
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  "#{Rails.root}/app/views", namespace: Views
)

Rails.autoloaders.main.push_dir(
  "#{Rails.root}/app/components", namespace: Components
)
