# @summary Writes arbitrary hash data to a config file.
#
# Writes arbitrary hash data to a config file. Note: you must manually notify
# any Sensu services to restart them when using this defined resource type.
#
define sensu_standalone::write_json (
  $ensure = 'present',
  $owner = 'sensu',
  $group = 'sensu',
  $mode = '0775',
  $pretty = true,
  $content = {},
  $notify_list = [],
) {


  # Write the config file, using the native file resource and the
  # sensu_sorted_json function to format/sort the json.
  file { $title :
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => sensu_sorted_json($content, $pretty),
    notify  => $notify_list,
  }
}
