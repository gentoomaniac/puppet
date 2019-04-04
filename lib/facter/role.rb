if Facter.value(:hostname) =~ /^(\w+)-(\w+)-([a-z]+)-?(\d+)$/
  Facter.add('pod') do
    setcode do
      $1
    end
  end
  Facter.add('role') do
    setcode do
      $2
    end
  end
  Facter.add('pool') do
    setcode do
      $3
    end
  end
end
