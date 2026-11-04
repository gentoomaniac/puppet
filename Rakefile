# Local entry point for the checks that CI runs (.github/workflows/ci.yml).
#
#   bundle install
#   bundle exec rake lint        # syntax checks and linters
#   bundle exec rake spec        # compile every Arch host's catalog
#   bundle exec rake             # both
#
# Besides the gems, `lint` needs `shellcheck` and `yamllint` on the PATH.

require 'shellwords'

require_relative 'spec/vendored_modules'

OWN_MODULES = (Dir['modules/*'].select { |path| File.directory?(path) } -
               VENDORED_MODULES.map { |name| "modules/#{name}" }).sort

def own_files(pattern)
  OWN_MODULES.flat_map { |dir| Dir[File.join(dir, pattern)] }.sort
end

def shell_scripts
  own_files('files/**/*').select do |path|
    File.file?(path) && (path.end_with?('.sh') || File.open(path, &:gets).to_s.match?(%r{\A#!.*\b(ba)?sh\b}))
  end
end

desc 'Run all lint and syntax checks'
task lint: %w[lint:puppet_parser lint:epp lint:erb lint:puppet_lint lint:ruby lint:yaml lint:shell]

namespace :lint do
  desc 'puppet parser validate on all own .pp files'
  task :puppet_parser do
    files = ['manifests/site.pp'] + own_files('manifests/**/*.pp')
    sh 'puppet', 'parser', 'validate', *files
  end

  desc 'puppet epp validate on all own .epp files'
  task :epp do
    files = own_files('templates/**/*.epp')
    sh 'puppet', 'epp', 'validate', *files unless files.empty?
  end

  desc 'ruby syntax check on all own .erb files'
  task :erb do
    own_files('templates/**/*.erb').each do |file|
      sh "erb -P -x -T - #{file.shellescape} | ruby -c > /dev/null"
    end
  end

  desc 'puppet-lint on own modules and manifests (config: .puppet-lint.rc)'
  task :puppet_lint do
    sh 'puppet-lint', 'manifests', *OWN_MODULES
  end

  desc 'ruby -c on custom facts'
  task :ruby do
    Dir['lib/facter/*.rb'].sort.each { |file| sh 'ruby', '-c', file, verbose: false }
  end

  desc 'yamllint on hiera data, hiera.yaml and workflows (config: .yamllint)'
  task :yaml do
    sh 'yamllint', 'hiera', 'hiera.yaml', '.github/workflows'
  end

  # info/style findings are too noisy for the existing scripts
  desc 'shellcheck (warnings and errors only) on own shell scripts'
  task :shell do
    scripts = shell_scripts
    sh 'shellcheck', '--severity=warning', *scripts unless scripts.empty?
  end
end

desc 'Install the forge modules the catalogs need but the puppet gem lacks'
task :spec_prep do
  # The vendored modules in modules/ cover stdlib & co; `host` is not bundled
  # with the puppet gem since Puppet 6.
  target = 'spec/fixtures/modules'
  next if File.directory?("#{target}/host_core")

  sh 'puppet', 'module', 'install', 'puppetlabs-host_core', '--version', '2.1.0',
     '--target-dir', target, '--ignore-dependencies'
end

desc 'Compile the catalog of every Arch host (rspec-puppet)'
task spec: :spec_prep do
  sh 'rspec', 'spec/hosts'
end

task default: %i[lint spec]
