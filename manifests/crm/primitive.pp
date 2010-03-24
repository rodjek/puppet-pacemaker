define ha::crm::primitive($class_name, $ensure=present, $monitor_interval, $ignore_dc="false", $stickiness="undef") {
    if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
        if($ensure == absent) {
            exec { "Removing primitive ${name}":
                command => "/usr/sbin/crm_resource -D -r ${name} -t primitive",
                onlyif  => "/usr/sbin/crm_resource -r ${name} -t primitive -q > /dev/null 2>&1",
            }
        } else {
            exec { "Creating primitive ${name}":
                command => "/usr/sbin/crm configure primitive ${name} ${class_name} op monitor interval=\"${monitor_interval}\"",
                unless  => "/usr/sbin/crm_resource -r ${name} -t primitive -q > /dev/null 2>&1",
            }

			if($stickiness != "undef") {
				ha::parameter { "${name}-resource-stickiness":
					resource  => $name,
					parameter => "resource-stickiness",
					value     => $stickiness,
					require   => Exec["Creating primitive ${name}"],
				}
			}
        }
    }
}
