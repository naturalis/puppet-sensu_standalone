#
#
#
define sensu_standalone::keys::client (
  $private,
  $cert,
  $private_keyname = '/etc/ssl/rabbitmq_client_key.pem',
  $cert_keyname    = '/etc/ssl/rabbitmq_client_cert.pem'
){

  file { $private_keyname :
    ensure  => present,
    content => $private,
    mode    => '0644',
  }

  file { $cert_keyname :
    ensure  => present,
    content => $cert,
    mode    => '0644',
  }

}
