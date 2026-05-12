# frozen_string_literal: true

module RubyUI
  module Toast
    FLASH_VARIANTS = {
      "notice" => :info,
      "alert" => :warning,
      "success" => :success,
      "error" => :error,
      "warning" => :warning,
      "info" => :info
    }.freeze

    def self.flash_variant(key)
      FLASH_VARIANTS[key.to_s] || :default
    end
  end
end
