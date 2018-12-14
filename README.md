puppet-sensu_standalone
=================

Role for deploying Sensu in a standalone environment.


## configuring sensu client
Configure parameters in params.pp 

Sensu client has the following input variables.
```
$processes_to_check = [],
```
This is a array of processes you want to check if they are running. This could be for example `['mysql','apache2']`
```
$plugins = []
```
This is an array of plugins which can be installed as gem. For example https://rubygems.org/gems/sensu-plugins-disk-checks. Search for gems with `sensu-plugins*`
```
$checks = { 'check_name'  => {'command' => 'echo "your command to run, return 0 if ok, 1 if warning 2 if error"'}}
```
This is a hash (not an array of hashes) of check definitions you can add to the server. They will be combined with the default checks. `check_name` should be unique.
```
$checks_defaults    = {
  interval      => 600,
  occurrences   => 3,
  refresh       => 60,
  handlers      => [ 'default'],
  subscribers   => ['appserver'],
  standalone    => true },
```
These are the default parameters of the check. If you override this here it will be overridden for all checks on this server. If you want for 1 check change `occurences` you can do add the occurrrens key value to the $checks. For example:
```
$checks = { 'check_name'  => {'command' => 'echo "your command to run, return 0 if ok, 1 if warning 2 if error"'. occurrences => 10}}
```

```
$check_load         = true,
$load_warning       = '99,0.95,0.9',
$load_critical      = '99,0.99,0.95',
```
There variables configure the default check of the CPU load. You can disable the check, or change the warning and critical levels.

```
$check_disk         = true,
$disk_warning       = 85,
$disk_critical      = 95,
```
There variables configure the default check of free diskspace. You can disable the check, or change the warning and critical levels.

```
$reboot_warning     = true,
```
You can disable or enable checking for reboot. Works on Ubuntu only.
```
$subscriptions      = ['appserver'],
```
To which channels to subribe. Not really in effect in our design. Might be handy to catagorise servers.

```
$client_cert,
$client_key,
$rabbitmq_password  = 'bladiebla',
$sensu_server       = '127.0.0.1',
```
There are central configurations, no need to change them, once they are configured correctly.

## configure sensu server

You can now set multipe uchiwa connections to different sensu servers.

configure the array `$extra_uchiwa_cons` as
```
- name: 'extra server name'
  host: 'dns or ip of new host'
  ssl: true
  insecure: true
  port: 8443
  user: 'your api username'
  pass: 'your api password'
  timeout: 5
- name: 'extra server name 2'
  host: 'dns or ip of new host 2'
  ssl: true
  insecure: true
  port: 8443
  user: 'your api username'
  pass: 'your api password'
  timeout: 5
```

On the server where you want to connect you have to expose the api to the outside world. You can do this by setting the variable `$expose_api = true`. This will expose the api on port 8443 over ssl.
