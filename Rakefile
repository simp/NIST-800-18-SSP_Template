#!/usr/bin/rake -T
# encoding: utf-8

require 'find'
require 'inifile'
require 'ostruct'
require 'rake/clean'
require 'yaml'

PROJECT_CONFIG_FILE='project_config.ini'

CLEAN.include 'build'
CLEAN.include 'linkcheck'
CLEAN.include 'html'
CLEAN.include 'html-single'
CLEAN.include 'pdf'
CLEAN.include 'sphinx_cache'
CLEAN.include 'docs/dynamic'
CLEAN.include 'docs/references/control.rst'

def find_erb_files(dir=File.join(File.dirname(__FILE__), 'docs'))
  to_ret = []
  Find.find(dir) do |erb|
    if erb =~ /\.erb$/
      to_ret << erb
    end
  end

  to_ret
end

## Custom Linting Checks

def lint_files_with_bad_tags
  file_issues = Hash.new()

  files_with_bad_tags = %x(grep -rne ':[[:alpha:]]\\+`[[:alpha:]]' docs).lines

  files_with_bad_tags.each do |line|
    line.strip!

    line_parts = line.split(': ')

    file_name = line_parts.shift
    issue_text = line_parts.join(': ')

    file_issues[file_name] = {
      :issue_type => 'bad_tag',
      :issue_text => issue_text
    }
  end

  file_issues
end

def run_build_cmd(cmd)
  require 'open3'

  puts "== #{cmd}"

  stdout, stderr, status = Open3.capture3(cmd)

  # This message is garbage
  stderr.gsub!(/WARNING: The config value \S+ has type \S+, defaults to \S+\./,'')
  stderr.strip!

  unless stderr.empty?
    $stderr.puts(stderr)
    exit(1)
  end

  return status
end

def load_project_config(config_ini)
  project_config = config_ini.to_h
  project_config[:internal] = {}

  project_config['BUILD'] ||= {}

  # Try to figure out where saxon is
  unless project_config['BUILD']['Saxon_Path']
    saxon_paths = [
      '/usr/share/java/',
      '/usr/share/java/saxon/'
    ]

    saxon_paths.each do |path|
      saxon_path = File.join(path, 'saxon.jar')

      if File.exist?(saxon_path)
        project_config['BUILD']['Saxon_Path'] = saxon_path
        break
      end
    end
  end

  unless project_config['BUILD']['Saxon_Path'] &&
      File.exist?(project_config['BUILD']['Saxon_Path'])

    $stderr.puts("ERROR: Could not find valid path for 'saxon.jar'")
    exit(1)
  end

  project_config[:internal][:controls_path] = File.expand_path(
    "#{project_config['CONFIG']['Reference_Policy']}".gsub(/\s+/,'').downcase,
    File.join('docs', 'references', 'controls')
  )

  unless File.directory?(project_config[:internal][:controls_path])
    fail "Could not find '#{project_config[:internal][:controls_path]}'"
  end

  project_config[:internal][:controls_file] = File.join(
    project_config[:internal][:controls_path],
    'controls.xml'
  )

  unless File.exist?(project_config[:internal][:controls_file])
    fail "Could not find '#{project_config[:internal][:controls_file]}'"
  end

  project_config[:internal][:controls_base_xsl] = File.join(
    project_config[:internal][:controls_path],
    'XSLT',
    project_config['CONFIG']['FIPS_199_Level'].downcase,
    'to_rst.xsl'
  )

  unless File.exist?(project_config[:internal][:controls_base_xsl])
    fail "Could not find '#{project_config[:internal][:controls_base_xsl]}'"
  end

  project_config[:internal][:controls_component_xsl] = File.join(
    project_config[:internal][:controls_path],
    'XSLT',
    project_config['CONFIG']['FIPS_199_Level'].downcase,
    'to_controls.xsl'
  )

  unless File.exist?(project_config[:internal][:controls_component_xsl])
    fail "Could not find '#{project_config[:internal][:controls_component_xsl]}'"
  end

  return project_config
end

## End Custom Linting Checks

fail("Could not find project config at '#{PROJECT_CONFIG_FILE}'") unless File.exist?(PROJECT_CONFIG_FILE)

@project_config = load_project_config(IniFile.load(PROJECT_CONFIG_FILE))

task :clean do
  find_erb_files.each do |erb|
    short_name = "#{File.dirname(erb)}/#{File.basename(erb,'.erb')}"
    if File.exist?(short_name)
      rm(short_name)
    end
  end
end

namespace :docs do
  task :generate_reference do
    target_file = File.join(@project_config[:internal][:controls_path], '..', 'controls.rst')

    input = @project_config[:internal][:controls_file]
    xsl = @project_config[:internal][:controls_base_xsl]
    output = %x{java -jar #{@project_config['BUILD']['Saxon_Path']} -xsl:#{xsl} -s:#{input}}

    File.open(target_file, 'w') do |fh|
      fh.puts(output)
    end
  end

  desc 'Generate the contents of docs/security_controls from the internal XML templates'
  task :generate_controls do
    controls_dir = File.join('docs', 'security_controls')

    canary = File.join(controls_dir, '00_README_BUILD_CONTROL.no_rst')

    input = @project_config[:internal][:controls_file]
    xsl = @project_config[:internal][:controls_component_xsl]

    # Split the output on the tear lines and preserve the filenames
    output = %x{java -jar #{@project_config['BUILD']['Saxon_Path']} -xsl:#{xsl} -s:#{input}}
      .split(/(?:\.+\s*)?\++TEAR\|(.+)\|TEAR\++/)
      .map(&:strip)

    output.delete_if(&:empty?)

    Hash[*output].each do |file, content|
      target_file = File.join(controls_dir, file)

      # Skip files that don't exist if we're not doing a full build since that
      # indicates that they were manually removed from the conrols
      next if File.exist?(canary) && !File.exist?(target_file)

      # Skip files that have already been modified
      next if File.exist?(target_file) &&
        (
          File.directory?(target_file) ||
          !File.read(target_file).include?('!!AUTO_OVERWRITE!!')
        )

      FileUtils.mkdir_p(File.dirname(target_file))

      File.open(target_file, 'w') do |fh|
        fh.puts(content)
      end
    end

    File.open(canary, 'w') do |fh|
      fh.puts <<-EOM
The presence of this file will cause the build system to not re-create any
files that do not exist in the current structure.

This is so that you can remove any controls that you do not feel are
appropriate for your environment while still being able to run the build
scripts unfettered.

If you remove this file, any missing files will be recreated all the way down
the stack.
      EOM
    end
  end

  desc 'basic linting tasks'
  task :lint => [:generate_reference, :generate_controls] do
    file_issues = Hash.new()

    puts "Starting doc linting"
    puts "Checking for bad tags..."

    file_issues.merge!(lint_files_with_bad_tags)

    unless file_issues.empty?
      msg = ["The following issues were found:"]

      file_issues.keys.each do |file|
        msg << "  * #{file}"
        msg << "    * Issue Type: #{file_issues[file][:issue_type]}"
        msg << "    * Issue Message: #{file_issues[file][:issue_text]}"
        msg << ''
      end

      $stderr.puts(msg)
      exit(1)
    end

    puts "Linting Complete"
  end

  desc 'build HTML docs'
  task :html => [:lint] do
    extra_args = ''
    cmd = "sphinx-build -E -n #{extra_args} -b html -d sphinx_cache docs html"
    run_build_cmd(cmd)
  end

  namespace :html do
    desc 'build HTML docs (single page)'
    task :single => [:lint] do
      extra_args = ''
      cmd = "sphinx-build -E -n #{extra_args} -b singlehtml -d sphinx_cache docs html-single"
      run_build_cmd(cmd)
    end
  end

  desc 'build Sphinx PDF docs using the RTD resources (SLOWEST) TODO: BROKEN'
  task :sphinxpdf => [:lint] do
    [ "sphinx-build -E -n -b latex -D language=en -d sphinx_cache docs latex",
      "pdflatex -interaction=nonstopmode -halt-on-error ./latex/*.tex"
    ].each do |cmd|
      run_build_cmd(cmd)
    end
  end

  desc 'build PDF docs (SLOWEST)'
  task :pdf => [:lint] do
    extra_args = ''
    cmd = "sphinx-build -E -n #{extra_args} -b pdf -d sphinx_cache docs pdf"
    run_build_cmd(cmd)
  end

  desc 'Check for broken external links'
  task :linkcheck => [:lint] do
    cmd = "sphinx-build -E -n -b linkcheck -d sphinx_cache docs linkcheck"
    run_build_cmd(cmd)
  end

  desc 'run a local web server to view HTML docs on http://localhost:5000'
  task :server, [:port] => [:html] do |_t, args|
    port = args.to_hash.fetch(:port, 5000)
    puts "running web server on http://localhost:#{port}"
    %x(ruby -run -e httpd html/ -p #{port})
  end
end
