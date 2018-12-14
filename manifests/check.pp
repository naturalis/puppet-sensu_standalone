#
define sensu_standalone::check (
  $command = undef,
  $ensure = 'present',
  $type = undef,
  $handlers = undef,
  $contacts = undef,
  $standalone = true,
  $cron = 'absent',
  $interval = 60,
  $occurrences = undef,
  $refresh = undef,
  $source = undef,
  $subscribers = undef,
  $low_flap_threshold = undef,
  $high_flap_threshold = undef,
  $timeout = undef,
  $aggregate = undef,
  $aggregates = undef,
  $handle = undef,
  $publish = undef,
  $dependencies = undef,
  $custom = undef,
  $content = {},
  $ttl = undef,
  $ttl_status = undef,
  $auto_resolve = undef,
  $subdue = undef,
  $proxy_requests = undef,
  $hooks = undef,
) {

  if $ensure == 'present' and !$command {
    fail("sensu_standalone::check{${name}}: a command must be given when ensure is present")
  }

  $check_name = regsubst(regsubst($name, ' ', '_', 'G'), '[\(\)]', '', 'G')

  # If cron is specified, interval should not be written to the configuration
  if $cron and $cron != 'absent' {
    $interval_real = 'absent'
  } else {
    $interval_real = $interval
  }

  $file_mode = '0440'

  # (#463) All plugins must come before all checks.  Collections are not used to
  # avoid realizing any resources.
  Anchor['plugins_before_checks']
  ~> Sensu_standalone::Check[$name]

  # This Hash map will ultimately exist at `{"checks" => {"$check_name" =>
  # $check_config}}`
  $check_config_start = {
    type                => $type,
    standalone          => $standalone,
    command             => $command,
    handlers            => $handlers,
    contacts            => $contacts,
    cron                => $cron,
    interval            => $interval_real,
    occurrences         => $occurrences,
    refresh             => $refresh,
    source              => $source,
    subscribers         => $subscribers,
    low_flap_threshold  => $low_flap_threshold,
    high_flap_threshold => $high_flap_threshold,
    timeout             => $timeout,
    aggregate           => $aggregate,
    aggregates          => $aggregates,
    handle              => $handle,
    publish             => $publish,
    dependencies        => $dependencies,
    subdue              => $subdue,
    proxy_requests      => $proxy_requests,
    hooks               => $hooks,
    ttl                 => $ttl,
    ttl_status          => $ttl_status,
    auto_resolve        => $auto_resolve,
  }

  # Remove key/value pares where the value is `undef` or `"absent"`.
  $check_config_pruned = $check_config_start.reduce({}) |$memo, $kv| {
    $kv[1] ? {
      undef    => $memo,
      'absent' => $memo,
      default  => $memo + Hash.new($kv),
    }
  }

  # Merge the specified properties on top of the custom hash.
  if $custom == undef {
    $check_config = $check_config_pruned
  } else {
    $check_config = $custom + $check_config_pruned
  }

  # Merge together the "checks" scope with any arbitrary config specified via
  # `content`.
  $checks_scope_start = { $check_name => $check_config }
  if $content['checks'] == undef {
    $checks_scope = { 'checks' => $checks_scope_start }
  } else {
    $checks_scope = { 'checks' => $content['checks'] + $checks_scope_start }
  }

  # The final structure from the top level.  Check configuration scope is merged
  # on top of any arbitrary plugin and extension configuration in $content.
  $content_real = $content + $checks_scope

  sensu_standalone::write_json { "/etc/sensu/conf.d/checks/${check_name}.json":
    ensure      => $ensure,
    content     => $content_real,
    owner       => 'sensu',
    group       => 'sensu',
    mode        => $file_mode,
    notify      => Service['sensu-client'],
  }
}
