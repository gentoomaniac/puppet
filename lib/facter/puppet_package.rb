# Which Arch package provides /usr/bin/puppet: 'openvox' or 'puppet'.
# Used by hostbase::puppet to switch hosts from Arch's stale puppet package to openvox.
Facter.add('puppet_package') do
  confine kernel: 'Linux'
  confine { File.executable?('/usr/bin/pacman') }

  setcode do
    owner = Facter::Core::Execution.execute('/usr/bin/pacman -Qqo /usr/bin/puppet', on_fail: nil)
    owner.nil? || owner.strip.empty? ? nil : owner.strip
  end
end
