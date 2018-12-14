#
define sensu_standalone::check (
  $command              = undef,
  $ensure               = 'present',
  $interval             = $sensu_standalone::checks_defaults['interval'],
  $occurrences          = $sensu_standalone::checks_defaults['occurrences'],
  $refresh              = $sensu_standalone::checks_defaults['refresh'],
  $handlers             = $sensu_standalone::checks_defaults['handlers'],
  $subscribers          = $sensu_standalone::checks_defaults['subscribers'],
  $standalone           = $sensu_standalone::checks_defaults['standalone'],
) {

  $check_name = $title

  file { "/etc/sensu/conf.d/checks/${title}.json":
    ensure      => $ensure,
    content     => template('sensu_standalone/check.erb'),
    owner       => 'sensu',
    group       => 'sensu',
    mode        => '400',
    notify      => Service['sensu-client'],
    require     => File['/etc/sensu/conf.d/checks']
  }
}

