require "open3"

module ShadcnAudit
  class Shell
    class Error < StandardError; end

    def capture(*argv, chdir: nil)
      opts = chdir ? {chdir: chdir.to_s} : {}
      stdout, stderr, status = Open3.capture3(*argv, **opts)
      raise Error, stderr unless status.success?
      stdout
    end
  end
end
