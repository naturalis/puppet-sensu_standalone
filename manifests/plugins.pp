#
#
#
class sensu_standalone::plugins ($plugins = {}) { create_resources('sensu_standalone::plugin_installer', $plugins, {}) }
