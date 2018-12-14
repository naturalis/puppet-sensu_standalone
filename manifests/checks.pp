#
#
#
class sensu_standalone::checks(
    $checks,
    $defaults,
)
{
 create_resources( 'sensu_standalone::check', $checks, $defaults )
}
