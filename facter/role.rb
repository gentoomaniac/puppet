# ([a-z]+)[0-9]+, i.e. www01 or logger22 have a puppet_role of www or logger
if Facter.value(:hostname) =~ /^(\w+)-(\w+)-([a-z]+)-?(\d+)$/
  Facter.add('pod') do
    setcode do
      $2
    end
  end
  Facter.add('role') do
    setcode do
      $2
    end
  end
  Facter.add('pool') do
    setcode do
      $2
    end
  end
end
