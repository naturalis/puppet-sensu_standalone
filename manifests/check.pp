#
define sensu_standalone::check (
  $command = undef,
  $ensure = 'present',
  $handlers = undef,
  $interval = 60,
  $occurrences = undef,
  $refresh = undef,
  $source = undef,
  $subscribers = undef,
) {

  $check_name = $title

  file { "/etc/sensu/conf.d/checks/${title}.json":
    ensure      => $ensure,
    content     => template('sensu_standalone/check.erb'),
    owner       => 'sensu',
    group       => 'sensu',
    mode        => '400',
    notify      => Service['sensu-client'],
  }
}

