#
#
#
class sensu_standalone::checks(
    $checks,
)
{
 create_resources( 'sensu_standalone::check', $checks )
}
