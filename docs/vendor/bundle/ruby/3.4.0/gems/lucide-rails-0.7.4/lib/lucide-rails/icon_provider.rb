# frozen_string_literal: true

module LucideRails
  module IconProvider
    module_function

    def icon(named)
      send("provide_from_#{LucideRails.provider}", named)
    end

    def provide_from_filesystem(named)
      file = LucideRails::GEM_ROOT.join("icons", "stripped", "#{named}.svg")
      raise ArgumentError, "Unknown icon #{named}" unless file.exist?

      File.read(file)
    end

    def provide_from_memory(named)
      named = named.to_s
      raise ArgumentError, "Unknown icon #{named}" unless memory.key? named

      memory[named]
    end

    def memory
      return @memory if @memory

      file_path = LucideRails::GEM_ROOT.join("icons/stripped.bin.gz")
      data = ActiveSupport::Gzip.decompress(File.read(file_path))
      @memory = data.split("\x00").to_h { |x| x.split(",", 2) }
    end
  end
end
