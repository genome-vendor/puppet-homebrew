class homebrew::install {

  $dir = '/usr/local'
  file { $dir:
    ensure  => directory,
    owner   => $homebrew::user,
    group   => $homebrew::group,
    mode    => '0775',
  }

  exec { "chown ${dir} user ${homebrew::user}":
    command => "chown -R ${homebrew::user} ${dir}",
    unless  => "test $(find ${dir} -type f -not -user ${homebrew::user} | wc -l) -eq 0",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ],
    require => File[$dir],
  }

  exec { "chown ${dir} group ${homebrew::group}":
    command => "chown -R :${homebrew::group} ${dir}",
    unless  => "test $(find ${dir} -type f -not -group ${homebrew::group} | wc -l) -eq 0",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ],
    require => File[$dir],
  }

  exec { "chmod ${dir}":
    command => "find ${dir} -not -type l -not -perm 0775 -print0 | xargs -0 chmod 0775",
    unless  => "test $(find ${dir} -not -type l -not -perm 0775 | wc -l) -eq 0",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ],
    require => File[$dir],
  }

  exec { 'install-homebrew':
    cwd       => $dir,
    command   => "/usr/bin/su ${homebrew::user} -c '/bin/bash -o pipefail -c \"/usr/bin/curl -skSfL https://github.com/homebrew/brew/tarball/master | /usr/bin/tar xz -m --strip 1\"'",
    creates   => "${dir}/bin/brew",
    logoutput => on_failure,
    timeout   => 0,
    require   => File[$dir],
  } ~>
  file { '/usr/local/bin/brew':
    owner => $homebrew::user,
    group => $homebrew::group,
    mode  => '0775',
  }
}
