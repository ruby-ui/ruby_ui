require 'mini_portile2/mini_portile'
require 'open3'

class MiniPortileCMake < MiniPortile
  attr_accessor :system_name

  def configure_prefix
    "-DCMAKE_INSTALL_PREFIX=#{File.expand_path(port_path)}"
  end

  def initialize(name, version, **kwargs)
    super(name, version, **kwargs)
    @cmake_command = kwargs[:cmake_command]
    @cmake_build_type = kwargs[:cmake_build_type]
  end

  def configure_defaults
    [
      generator_defaults,
      cmake_compile_flags,
    ].flatten
  end

  def configure
    return if configured?

    cache_file = File.join(tmp_path, 'configure.options_cache')
    File.open(cache_file, "w") { |f| f.write computed_options.to_s }

    execute('configure', [cmake_cmd] + computed_options + ["."])
  end

  def configured?
    configure = File.join(work_path, 'configure')
    makefile  = File.join(work_path, 'CMakefile')
    cache_file  = File.join(tmp_path, 'configure.options_cache')

    stored_options  = File.exist?(cache_file) ? File.read(cache_file) : ""
    current_options = computed_options.to_s

    (current_options == stored_options) && newer?(makefile, configure)
  end

  def make_cmd
    return "nmake" if MiniPortile.mswin?
    super
  end

  def cmake_cmd
    (ENV["CMAKE"] || @cmake_command || "cmake").dup
  end

  def cmake_build_type
    (ENV["CMAKE_BUILD_TYPE"] || @cmake_build_type || "Release").dup
  end

  private

  def generator_defaults
    if MiniPortile.mswin? && generator_available?('NMake')
      ['-G', 'NMake Makefiles']
    elsif MiniPortile.mingw? && generator_available?('MSYS')
      ['-G', 'MSYS Makefiles']
    else
      []
    end
  end

  def cmake_compile_flags
    # RbConfig::CONFIG['CC'] and RbConfig::CONFIG['CXX'] can contain additional flags, for example
    # "clang++ -std=gnu++11" or "clang -fdeclspec". CMake is just looking for the command name.
    cc_compiler = cc_cmd.split.first
    cxx_compiler = cxx_cmd.split.first

    # needed to ensure cross-compilation with CMake targets the right CPU and compilers
    [
      "-DCMAKE_SYSTEM_NAME=#{cmake_system_name}",
      "-DCMAKE_SYSTEM_PROCESSOR=#{cpu_type}",
      "-DCMAKE_C_COMPILER=#{cc_compiler}",
      "-DCMAKE_CXX_COMPILER=#{cxx_compiler}",
      "-DCMAKE_BUILD_TYPE=#{cmake_build_type}",
    ]
  end

  # Full list: https://gitlab.kitware.com/cmake/cmake/-/blob/v3.26.4/Modules/CMakeDetermineSystem.cmake?ref_type=tags#L12-31
  def cmake_system_name
    return system_name if system_name

    if MiniPortile.linux?
      'Linux'
    elsif MiniPortile.darwin?
      'Darwin'
    elsif MiniPortile.windows?
      'Windows'
    elsif MiniPortile.freebsd?
      'FreeBSD'
    elsif MiniPortile.openbsd?
      'OpenBSD'
    elsif MiniPortile.solaris?
      'SunOS'
    else
      raise "Unable to set CMAKE_SYSTEM_NAME for #{MiniPortile.target_os}"
    end
  end

  def generator_available?(generator_type)
    stdout_str, status = Open3.capture2("#{cmake_cmd} --help")

    raise 'Unable to determine whether CMake supports #{generator_type} Makefile generator' unless status.success?

    stdout_str.include?("#{generator_type} Makefiles")
  end

  def cpu_type
    return 'x86_64' if MiniPortile.target_cpu == 'x64'

    MiniPortile.target_cpu
  end
end
