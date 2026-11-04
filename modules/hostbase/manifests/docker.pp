# @summary Docker daemon configuration
class hostbase::docker {
  file { '/etc/docker':
    ensure => directory,
  }

  file { '/etc/docker/daemon.json':
    ensure  => present,
    mode    => '0644',
    content => file('hostbase/docker-daemon.json'),
    require => [File['/etc/docker'], Package['docker']],
    notify  => Service['docker'],
  }

  # one-off: drop the containerd image store once docker runs on the classic overlay2 driver
  exec { 'cleanup-containerd-image-store':
    command  => @(CMD/L),
      systemctl stop docker.service docker.socket containerd.service && \
      rm -rf /var/lib/containerd/io.containerd.content.v1.content \
      /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs \
      /var/lib/containerd/io.containerd.metadata.v1.bolt && \
      systemctl start docker.service
      |- CMD
    onlyif   => @(TEST/L),
      test "$(docker info --format '{{.Driver}}')" = overlay2 && \
      test -n "$(ls -A /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256 2>/dev/null)"
      |- TEST
    provider => shell,
    path     => ['/bin', '/usr/bin'],
    require  => Service['docker'],
  }
}
