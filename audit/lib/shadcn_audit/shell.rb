require "open3"

module ShadcnAudit
  class Shell
    class Error < StandardError; end

    def capture(*argv, chdir: nil)
      opts = chdir ? {chdir: chdir.to_s} : {}
      stdout, stderr, status = Open3.capture3(*argv, **opts)
      return stdout if status.success?

      detail = stderr.strip.empty? ? "exit #{status.exitstatus}" : stderr.strip
      raise Error, "#{argv.join(" ")} failed: #{detail}"
    end
  end
end
