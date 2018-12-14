#
#
#
class role_sensu::foreman(
  $hammer_user,
  $hammer_password,
)
{

# create svn update check script for for usage with monitoring tools ( sensu )
  file {'/usr/local/sbin/foremanchk.sh':
    ensure        => 'file',
    mode          => '0755',
    content       => template('role_sensu/foremanchk.sh.erb')
  }

  cron { 'foremancheck':
    command => '/usr/local/sbin/foremanchk.sh cron',
    user    => 'root',
    minute  => '*/10',
    require => File['/usr/local/sbin/foremanchk.sh']
  }

# export check so sensu monitoring can make use of it
  @sensu::check { 'Check_foreman_hosts' :
    command       => '/usr/local/sbin/foremanchk.sh report',
    tag           => 'central_sensu',
 }

}
