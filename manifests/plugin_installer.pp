#
#
#
define sensu_standalone::plugin_installer (
) {

  exec { "Installing Sensu Gem: ${title}" :
    command => "/opt/sensu/embedded/bin/gem install ${title}",
    unless  => "/opt/sensu/embedded/bin/gem list --local | grep ${title}",
    require => Service['sensu-client'],
  }

}
