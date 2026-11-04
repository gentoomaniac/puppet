require 'fileutils'
require 'yaml'
require 'rspec-puppet'
require_relative 'vendored_modules'

REPO_ROOT = File.expand_path('..', __dir__)
FIXTURES = File.join(REPO_ROOT, 'spec', 'fixtures')
GENERATED = File.join(FIXTURES, 'generated')

# Hiera for CI: the real hiera.yaml hierarchy, but without the hiera_vault
# level (CI cannot reach Vault), plus a stub level that answers every
# secret_* key found in hiera/ and modules/ with a dummy value.
def write_test_hiera
  FileUtils.mkdir_p(GENERATED)

  own_module_files = Dir[File.join(REPO_ROOT, 'modules', '*', '**', '*')].reject do |path|
    File.directory?(path) || VENDORED_MODULES.include?(path.delete_prefix("#{REPO_ROOT}/modules/").split('/').first)
  end
  sources = Dir[File.join(REPO_ROOT, 'hiera', '**', '*.yaml')] + own_module_files
  secret_keys = sources.flat_map { |path| File.read(path).scan(/\bsecret_\w+/) }.uniq.sort
  File.write(File.join(GENERATED, 'secrets.yaml'),
             secret_keys.to_h { |key| [key, "dummy-#{key}"] }.to_yaml)

  config = YAML.load_file(File.join(REPO_ROOT, 'hiera.yaml'))
  config['defaults']['datadir'] = File.join(REPO_ROOT, config['defaults']['datadir'])
  config['hierarchy'].reject! { |level| level['lookup_key'] == 'hiera_vault' }
  config['hierarchy'].unshift('name' => 'Dummy secrets', 'datadir' => GENERATED, 'path' => 'secrets.yaml')
  hiera_config = File.join(GENERATED, 'hiera.yaml')
  File.write(hiera_config, config.to_yaml)
  hiera_config
end

RSpec.configure do |config|
  config.module_path = [File.join(REPO_ROOT, 'modules'), File.join(FIXTURES, 'modules')].join(':')
  config.manifest = File.join(REPO_ROOT, 'manifests', 'site.pp')
  config.hiera_config = write_test_hiera
end
