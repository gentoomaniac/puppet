begin
  branch = File.open("/etc/puppet_branch", &:readline)
rescue
  branch = 'master'
end
Facter.add('puppet_branch') do
  setcode do
    branch.strip
  end
end
