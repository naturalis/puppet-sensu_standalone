#
# == Parameters
#
class sensu_standalone::install_apt_repo {

  $repo_key_id = 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB'
  $repo_key_source = 'https://sensu.global.ssl.fastly.net/apt/pubkey.gpg'

  if defined(apt::source) {

    # $ensure = $sensu::install_repo ? {
    #   true    => 'present',
    #   default => 'absent'
    # }


    $url = 'https://sensu.global.ssl.fastly.net/apt'

    apt::source { 'sensu_repo':
      ensure   => present,
      location => $url,
      release  => 'sensu',
      repos    => 'main',
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => $repo_key_id,
        'source' => $repo_key_source,
      },
#      before   => Package['sensu'],
      notify   => Exec['apt-update'],
    }

    exec { 'apt-update-custom':
      refreshonly => true,
      command     => '/usr/bin/apt-get update',
    }

  } else {
    fail('This class requires puppetlabs-apt module')
  }

}
