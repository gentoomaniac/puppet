require 'spec_helper'

# One catalog compile per host, generated from the MAC files so that new hosts
# are covered automatically. Facts mimic what facter and lib/facter/role.rb
# report on a real host.

HOSTS = Dir[File.join(REPO_ROOT, 'hiera', 'mac', '*.yaml')].sort.map do |mac_file|
  [File.basename(mac_file, '.yaml'), YAML.load_file(mac_file) || {}]
end

# Without this, a moved MAC directory would give "0 examples, 0 failures".
describe 'host discovery' do
  it('finds at least one host to compile') { expect(HOSTS).not_to be_empty }
end

HOSTS.each do |mac, data|
  fqdn = data.fetch('hostbase::hostname::hostname') do
    raise "hiera/mac/#{mac}.yaml: hostbase::hostname::hostname is not set"
  end
  hostname, domain = fqdn.split('.', 2)
  # Same pattern as lib/facter/role.rb
  pod, role, pool = hostname.match(/^(\w+)-(\w+)-([a-z]+)-?(\d+)$/)&.captures

  describe "host #{fqdn} (#{mac})" do
    let(:node) { fqdn }
    let(:facts) do
      {
        'fqdn' => fqdn,
        'hostname' => hostname,
        'domain' => domain,
        'networking' => { 'mac' => mac, 'ip' => '192.0.2.1', 'fqdn' => fqdn, 'hostname' => hostname, 'domain' => domain },
        'pod' => pod,
        'role' => role,
        'pool' => pool,
        'kernel' => 'Linux',
        'os' => { 'family' => 'Archlinux', 'name' => 'Archlinux',
                  'release' => { 'major' => 'rolling', 'full' => 'rolling' },
                  'architecture' => 'x86_64', 'hardware' => 'x86_64' },
        'osfamily' => 'Archlinux',
        'operatingsystem' => 'Archlinux',
        'architecture' => 'x86_64',
        'systemd' => true,
        'puppet_branch' => 'master',
        'puppet_package' => 'openvox',
      }.compact # like facter, leave pod/role/pool undefined when the hostname doesn't match
    end

    it { is_expected.to compile.with_all_deps }
  end
end
