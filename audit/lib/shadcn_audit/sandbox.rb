require "fileutils"
require "yaml"
require "time"

module ShadcnAudit
  # Local Vite app made by the shadcn CLI (Base UI base, vega style, neutral
  # theme) that renders the shadcn side of every fixture in audit/fixtures.
  class Sandbox
    URL_TEMPLATE = "http://localhost:5179/?c={folder}&theme={light|dark}"
    # Written after a successful build: the audit/sandbox.yml pins (a
    # mismatch rebuilds the app), the workspace shadcn SHA the components were
    # added at, and when. A different workspace SHA re-adds the components.
    STAMP = ".audit-sandbox.yml"
    TEMPLATE_FILES = %w[src/main.tsx src/parity.css index.html].freeze

    def self.config(audit_dir) = YAML.safe_load_file(audit_dir.join("sandbox.yml").to_s)

    def initialize(shell:, dir:, shadcn_sha:, audit_dir: ShadcnAudit.root.join("audit"), clock: -> { Time.now.utc })
      @shell = shell
      @dir = Pathname.new(dir)
      @shadcn_sha = shadcn_sha
      @audit_dir = Pathname.new(audit_dir)
      @clock = clock
    end

    def prepare
      @stamp_data = nil
      created = !built?
      refreshed = !created && stamp_data["shadcn_sha"] != @shadcn_sha
      refreshed_from = stamp_data["shadcn_sha"] if refreshed
      if created
        build
      elsif refreshed
        refresh
      end
      copy_template
      copy_fixtures
      {
        "path" => app_dir.to_s, "url_template" => URL_TEMPLATE, "lock" => lock, "created" => created,
        "refreshed" => refreshed, "refreshed_from" => refreshed_from,
        "built_from_sha" => stamp_data["shadcn_sha"], "built_at" => stamp_data["built_at"]
      }
    end

    private

    def app_dir = @dir.join("sandbox")

    def stamp = app_dir.join(STAMP)

    def pins = @pins ||= self.class.config(@audit_dir)

    def shadcn_cli = "shadcn@#{pins.fetch("shadcn")}"

    def stamp_data
      @stamp_data ||= begin
        data = stamp.exist? ? YAML.safe_load(stamp.read) : nil
        data.is_a?(Hash) ? data : {}
      end
    end

    def built? = stamp_data["pins"] == pins

    def write_stamp
      @stamp_data = {"pins" => pins, "shadcn_sha" => @shadcn_sha, "built_at" => @clock.call.iso8601}
      stamp.write(YAML.dump(@stamp_data))
    end

    def add_components(*flags)
      @shell.capture("pnpm", "dlx", shadcn_cli, "add", "--yes", *flags, *shadcn_components, chdir: app_dir)
    end

    # The shadcn workspace moved since the build: re-add the mapped
    # components over the old ones, keeping the app and its packages.
    def refresh
      add_components("--overwrite")
      write_stamp
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
      add_components
      @shell.capture("pnpm", "add", *pins.fetch("packages").map { |name, version| "#{name}@#{version}" }, chdir: app_dir)
      write_stamp
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
      map.all_folders.map { |folder| map.entry(folder).fetch("shadcn") }.compact.uniq
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
