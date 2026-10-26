require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "shadcn_audit"

module ShadcnAudit
  # Records every call and returns canned stdout.
  #
  #   shell = FakeShell.new
  #   shell.stub(%w[git rev-parse HEAD], "abc\n")          # exact argv
  #   shell.stub(->(argv) { argv.first == "gh" }, "{}")    # matcher
  #   shell.stub_error(%w[git fetch], "boom")              # raises Shell::Error
  #
  # Unstubbed calls return "". Matching: first stub registered wins.
  class FakeShell
    Call = Struct.new(:argv, :chdir)

    attr_reader :calls

    def initialize
      @calls = []
      @stubs = []
    end

    def stub(key, output = "")
      @stubs << [key, output]
      self
    end

    def stub_error(key, message = "failed")
      @stubs << [key, Shell::Error.new(message)]
      self
    end

    def capture(*argv, chdir: nil)
      @calls << Call.new(argv, chdir&.to_s)
      _, result = @stubs.find { |key, _| matches?(key, argv) }
      raise result if result.is_a?(Exception)
      result || ""
    end

    def argvs
      @calls.map(&:argv)
    end

    def called?(*argv)
      argvs.include?(argv)
    end

    private

    def matches?(key, argv)
      key.respond_to?(:call) ? key.call(argv) : key == argv
    end
  end
end
