define ha::util::cleanup($resource, $host="") {
    if($ha_cluster_dc == $fqdn) {
        exec { "Reseting state for resource ${name}":
            command     => "/usr/sbin/crm resource cleanup ${resource} ${host} > /dev/null",
            refreshonly => true,
			returns     => 1,
        }
    }
}
