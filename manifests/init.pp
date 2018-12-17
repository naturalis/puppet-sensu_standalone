#
#
#
class sensu_standalone(
  $client_cert,
  $client_key,
  $rabbitmq_password  = 'bladiebla',
  $sensu_server       = '127.0.0.1',
  $plugins            = [],
  $checks             = {},
  $check_disk         = true,
  $disk_warning       = 85,
  $disk_critical      = 95,
  $check_load         = true,
  $load_warning       = '0.6,0.55,0.5',  # only used when load auto = false
  $load_critical      = '0.99,0.95,0.90', # only used when load auto = false
  $load_auto          = true,
  $reboot_warning     = true,
  $processes_to_check = [],
  $subscriptions      = ['appserver'],
  $handlers           = [ 'default'],
  $checks_defaults    = {
    interval      => 600,
    occurrences   => 3,
    refresh       => 60,
    handlers      => [ 'default'],
    subscribers   => ['appserver'],
    standalone    => true },
){

  $builtin_plugins = ['sensu-plugins-disk-checks', 'sensu-plugins-load-checks', 'sensu-plugins-process-checks' ]
  $ruby_run_comand = '/opt/sensu/embedded/bin/ruby -C/opt/sensu/embedded/bin'


# install client keys
  sensu_standalone::keys::client { 'client_keys' :
    private => $client_key,
    cert    => $client_cert,
  }

# install sensu 
  class { 'sensu_standalone::install_apt_repo': }
  package { 'sensu':
    require     => Class['sensu_standalone::install_apt_repo']
  }

# apt-update exec
  exec { 'apt-update':
    command     => '/usr/bin/apt update',
    refreshonly => true,
  }

# create checks dir
  file { '/etc/sensu/conf.d/checks':
    ensure  => 'directory',
    mode    => '0750',
    group   => 'sensu',
    require => Package['sensu'],
  }

# creating sensu rabbitmq config file
  file { 'rabbitmq_config':
    path    => '/etc/sensu/conf.d/rabbitmq.json',
    mode    => '0640',
    group   => 'sensu',
    content => template('sensu_standalone/rabbitmq.json.erb'),
    require => Package['sensu'],
  }

# creating sensu client config file
  file { 'client_config':
    path    => '/etc/sensu/conf.d/client.json',
    mode    => '0640',
    group   => 'sensu',
    content => template('sensu_standalone/client.json.erb'),
    require => Package['sensu'],
  }

# creating sensu daemon config file
  file { 'sensu_daemon':
    path    => '/etc/default/sensu',
    mode    => '0444',
    content => template('sensu_standalone/sensu.erb'),
  }

  service { 'sensu-client':
    ensure     => 'running',
    enable     => true,
    require    => [File['rabbitmq_config'],
                   File['client_config'],
                   File['sensu_daemon'],
                   File['/etc/ssl/rabbitmq_client_key.pem'],
                   File['/etc/ssl/rabbitmq_client_cert.pem'],
                  ]
  }

  if $reboot_warning {
    sensu_standalone::check { 'check_reboot_required':
      command     => 'if [ -f /var/run/reboot-required ] ; then echo reboot required ; return 1 ; else echo no reboot required ;fi',
    }
  }

  if $check_disk {
    sensu_standalone::check { 'check_disk_usage':
      command     => "${ruby_run_comand} check-disk-usage.rb -w ${disk_warning} -c ${disk_critical} -x tmpfs,overlay,nsfs,tracefs"
    }
    sensu_standalone::check { 'check_disk_mounts':
      command     => "${ruby_run_comand} check-fstab-mounts.rb"
    }
  }

  if $check_load {
    sensu_standalone::check { 'check_CPU_load':
      command     => "${ruby_run_comand} check-load.rb -w ${load_warning} -c ${load_critical}"
    }
  }

  if size($processes_to_check) > 0 {
    sensu_standalone::check_process_installer { $processes_to_check :
      checks_defaults => $checks_defaults,
    }
  }

  if $checks {
    create_resources( 'sensu_standalone::check', $checks )
  }

  $plugin_array = unique(concat($plugins, $builtin_plugins))
  sensu_standalone::plugin_installer { $plugin_array : }

}
