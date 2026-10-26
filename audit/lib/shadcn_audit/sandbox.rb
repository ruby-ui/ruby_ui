require "fileutils"
require "yaml"

module ShadcnAudit
  # Local Vite app made by the shadcn CLI (Base UI base, vega style, neutral
  # theme) that renders the shadcn side of every fixture in audit/fixtures.
  class Sandbox
    URL_TEMPLATE = "http://localhost:5179/?c={folder}&theme={light|dark}"
    # Copy of audit/sandbox.yml written after a successful build; a mismatch
    # means the pins changed and the app is rebuilt.
    STAMP = ".audit-sandbox.yml"
    TEMPLATE_FILES = %w[src/main.tsx src/parity.css index.html].freeze

    def self.config(audit_dir) = YAML.safe_load_file(audit_dir.join("sandbox.yml").to_s)

    def initialize(shell:, dir:, audit_dir: ShadcnAudit.root.join("audit"))
      @shell = shell
      @dir = Pathname.new(dir)
      @audit_dir = Pathname.new(audit_dir)
    end

    def prepare
      created = !built?
      build if created
      copy_template
      copy_fixtures
      {"path" => app_dir.to_s, "url_template" => URL_TEMPLATE, "lock" => lock, "created" => created}
    end

    private

    def app_dir = @dir.join("sandbox")

    def stamp = app_dir.join(STAMP)

    def pins = @pins ||= self.class.config(@audit_dir)

    def shadcn_cli = "shadcn@#{pins.fetch("shadcn")}"

    def built?
      stamp.exist? && YAML.safe_load(stamp.read) == pins
    end

    def build
      FileUtils.rm_rf(app_dir)
      FileUtils.mkdir_p(@dir)
      @shell.capture(
        "pnpm", "dlx", shadcn_cli, "init",
        "--template", pins.fetch("template"), "--base", pins.fetch("base"), "--preset", pins.fetch("preset"),
        "--name", "sandbox", "--no-monorepo", "--yes",
        chdir: @dir
      )
      verify_components_json
      @shell.capture("pnpm", "dlx", shadcn_cli, "add", "--yes", *shadcn_components, chdir: app_dir)
      @shell.capture("pnpm", "add", *pins.fetch("packages").map { |name, version| "#{name}@#{version}" }, chdir: app_dir)
      stamp.write(YAML.dump(pins))
    end

    def verify_components_json
      json = JSON.parse(app_dir.join("components.json").read)
      style = "#{pins.fetch("base")}-#{pins.fetch("preset")}"
      color = json.dig("tailwind", "baseColor")
      return if json["style"] == style && color == pins.fetch("base_color")
      raise ConfigError, "shadcn init produced style #{json["style"].inspect} / baseColor #{color.inspect}, " \
        "expected #{style.inspect} / #{pins.fetch("base_color").inspect}"
    end

    def shadcn_components
      map = ComponentMap.load(@audit_dir.join("component_map.yml"))
      map.all_folders.map { |folder| map.entry(folder).fetch("shadcn") }.uniq
    end

    def copy_template
      TEMPLATE_FILES.each do |path|
        target = app_dir.join(path)
        FileUtils.mkdir_p(target.dirname)
        FileUtils.cp(@audit_dir.join("sandbox_template", path), target)
      end
    end

    def copy_fixtures
      target = app_dir.join("src/fixtures")
      FileUtils.rm_rf(target)
      FileUtils.mkdir_p(target)
      Dir[@audit_dir.join("fixtures/*/shadcn.tsx").to_s].each do |source|
        FileUtils.cp(source, target.join("#{File.basename(File.dirname(source))}.tsx"))
      end
    end

    # Installed versions of the app's direct dependencies, from pnpm-lock.yaml
    # (falling back to package.json specifiers when there is no lockfile).
    def lock
      lockfile = app_dir.join("pnpm-lock.yaml")
      if lockfile.exist?
        deps = YAML.safe_load(lockfile.read).dig("importers", ".", "dependencies") || {}
        deps.transform_values { |dep| dep.fetch("version").to_s.split("(").first }
      else
        JSON.parse(app_dir.join("package.json").read).fetch("dependencies", {})
      end
    end
  end
end
