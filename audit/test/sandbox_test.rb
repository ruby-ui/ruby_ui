require "test_helper"

class SandboxTest < Minitest::Test
  AUDIT_DIR = ShadcnAudit.root.join("audit")
  FOLDERS = %w[dialog alert_dialog sheet command].freeze

  # Stands in for the shadcn CLI: `init` writes the files a real init leaves
  # behind (components.json, package.json, pnpm-lock.yaml).
  class ScaffoldingShell < ShadcnAudit::FakeShell
    attr_writer :components_json

    def capture(*argv, chdir: nil)
      result = super
      scaffold(Pathname.new(chdir).join("sandbox")) if argv.include?("init")
      result
    end

    private

    def scaffold(app)
      FileUtils.mkdir_p(app.join("src"))
      app.join("components.json").write(JSON.generate(@components_json || {"style" => "base-vega", "tailwind" => {"baseColor" => "neutral"}}))
      app.join("package.json").write(JSON.generate("dependencies" => {"shadcn" => "^4.22.1"}))
      app.join("pnpm-lock.yaml").write(<<~YAML)
        lockfileVersion: '9.0'
        importers:
          .:
            dependencies:
              '@base-ui/react':
                specifier: ^1.9.0
                version: 1.9.0(@types/react@19.2.2)(react@19.3.1)
              shadcn:
                specifier: ^4.22.1
                version: 4.22.1(typescript@6.0.2)
      YAML
    end
  end

  def setup
    @tmp = Dir.mktmpdir
    @dir = Pathname.new(@tmp)
    @app = @dir.join("sandbox")
    @shell = ScaffoldingShell.new
    @sandbox = ShadcnAudit::Sandbox.new(shell: @shell, dir: @dir)
    @pinned = ShadcnAudit::Sandbox.config(AUDIT_DIR)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def shadcn_cli = "shadcn@#{@pinned.fetch("shadcn")}"

  def init_argv = @shell.argvs.find { |argv| argv.include?("init") }

  def test_first_prepare_runs_init_with_base_vega_neutral
    result = @sandbox.prepare

    argv = init_argv
    assert_equal ["pnpm", "dlx", shadcn_cli, "init"], argv.first(4)
    assert_equal "vite", argv[argv.index("--template") + 1]
    assert_equal "base", argv[argv.index("--base") + 1]
    assert_equal "vega", argv[argv.index("--preset") + 1]
    assert_equal "sandbox", argv[argv.index("--name") + 1]
    # The CLI has no base-color flag: neutral comes with the vega preset and
    # is checked against the generated components.json.
    assert_equal "neutral", @pinned.fetch("base_color")
    assert_equal @dir.to_s, @shell.calls.find { |call| call.argv == argv }.chdir
    assert_equal true, result["created"]
    assert_equal @app.to_s, result["path"]
    assert_equal "http://localhost:5179/?c={folder}&theme={light|dark}", result["url_template"]
    assert_equal({"@base-ui/react" => "1.9.0", "shadcn" => "4.22.1"}, result["lock"])
  end

  def test_init_producing_another_style_or_color_raises
    @shell.components_json = {"style" => "base-nova", "tailwind" => {"baseColor" => "neutral"}}
    error = assert_raises(ShadcnAudit::ConfigError) { @sandbox.prepare }
    assert_match(/base-nova/, error.message)

    FileUtils.rm_rf(@app)
    @shell.components_json = {"style" => "base-vega", "tailwind" => {"baseColor" => "zinc"}}
    error = assert_raises(ShadcnAudit::ConfigError) { @sandbox.prepare }
    assert_match(/zinc/, error.message)
  end

  def test_adds_components_from_map
    @sandbox.prepare

    add = @shell.calls.find { |call| call.argv.include?("add") && call.argv.include?(shadcn_cli) }
    assert_equal ["pnpm", "dlx", shadcn_cli, "add", "--yes", "dialog", "alert-dialog", "sheet", "command"], add.argv
    assert_equal @app.to_s, add.chdir
    plugins = @pinned.fetch("packages").map { |name, version| "#{name}@#{version}" }
    assert @shell.called?("pnpm", "add", *plugins)
  end

  def test_copies_fixtures_and_parity_css
    @sandbox.prepare

    %w[src/main.tsx src/parity.css index.html].each do |path|
      assert_equal AUDIT_DIR.join("sandbox_template", path).read, @app.join(path).read, path
    end
    FOLDERS.each do |folder|
      assert_equal AUDIT_DIR.join("fixtures", folder, "shadcn.tsx").read, @app.join("src/fixtures/#{folder}.tsx").read
    end
    parity = @app.join("src/parity.css").read
    assert_includes parity, '@plugin "@tailwindcss/forms";'
    assert_includes parity, '@plugin "@tailwindcss/typography";'
    assert_includes parity, '@import "tw-animate-css";'
    assert_includes parity, "@apply bg-background text-foreground font-sans antialiased;"
  end

  def test_second_prepare_skips_init
    @sandbox.prepare
    @app.join("src/fixtures/dialog.tsx").write("stale")
    calls_before = @shell.calls.size

    result = @sandbox.prepare

    assert_equal false, result["created"]
    assert_equal calls_before, @shell.calls.size
    assert_equal AUDIT_DIR.join("fixtures/dialog/shadcn.tsx").read, @app.join("src/fixtures/dialog.tsx").read
  end

  def test_changed_pins_rebuild_the_sandbox
    @sandbox.prepare
    @app.join(ShadcnAudit::Sandbox::STAMP).write("shadcn: 0.0.1\n")
    @app.join("leftover.txt").write("x")

    result = @sandbox.prepare

    assert_equal true, result["created"]
    assert_equal 2, @shell.argvs.count { |argv| argv.include?("init") }
    refute @app.join("leftover.txt").exist?
  end

  def test_fixture_strings_match
    folders = Dir.children(AUDIT_DIR.join("fixtures")).sort
    assert_equal FOLDERS.sort, folders
    folders.each do |folder|
      dir = AUDIT_DIR.join("fixtures", folder)
      content = YAML.safe_load_file(dir.join("content.yml").to_s)
      shadcn = dir.join("shadcn.tsx").read
      rubyui = dir.join("rubyui.rb").read
      refute_empty content, folder
      content.values.flatten.each do |value|
        assert_includes shadcn, value, "#{folder}/shadcn.tsx is missing #{value.inspect}"
        assert_includes rubyui, value, "#{folder}/rubyui.rb is missing #{value.inspect}"
      end
      assert_equal 1, shadcn.scan("data-audit-trigger").size, "#{folder}/shadcn.tsx needs one data-audit-trigger"
      assert_equal 1, rubyui.scan("audit_trigger").size, "#{folder}/rubyui.rb needs one data-audit-trigger"
      assert_includes rubyui, "class #{folder.split("_").map(&:capitalize).join} < Phlex::HTML"
    end
  end
end
