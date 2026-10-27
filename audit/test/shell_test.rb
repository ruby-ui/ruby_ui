require "test_helper"
require "rbconfig"

class ShellTest < Minitest::Test
  def shell = ShadcnAudit::Shell.new

  # Children run outside the bundle: in CI, any process that loads bundler
  # prints constant-redefinition warnings to stderr, which would leak into
  # the error messages asserted below.
  def capture(*argv)
    return shell.capture(*argv) unless defined?(Bundler)
    Bundler.with_unbundled_env { shell.capture(*argv) }
  end

  def test_success_returns_stdout
    assert_equal "hi\n", capture(RbConfig.ruby, "-e", "puts 'hi'")
  end

  def test_failure_names_the_command_and_its_stderr
    argv = [RbConfig.ruby, "-e", "warn 'boom'; exit 3"]
    error = assert_raises(ShadcnAudit::Shell::Error) { capture(*argv) }
    assert_equal "#{argv.join(" ")} failed: boom", error.message
  end

  def test_failure_without_stderr_reports_the_exit_status
    argv = [RbConfig.ruby, "-e", "exit 4"]
    error = assert_raises(ShadcnAudit::Shell::Error) { capture(*argv) }
    assert_equal "#{argv.join(" ")} failed: exit 4", error.message
  end
end
