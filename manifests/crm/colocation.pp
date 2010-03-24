define ha::crm::colocation($score, $resource1_name, $resource1_role = "", $resource2_name, $resource2_role = "", $ensure = present) {
	if($ha_cluster_dc == $fqdn) {
		if($resource1_role != "") {
			$resource1 = "${resource1_name}:${resource1_role}"
		} else {
			$resource1 = $resource1_name
		}

		if($resource2_role != "") {
			$resource2 = "${resource2_name}:${resource2_role}"
		} else {
			$resource2 = $resource2_name
		}

		if($ensure == absent) {
			exec { "Removing colocation constraint ${name}":
				command => "/usr/sbin/crm configure delete ${name}",
				onlyif  => "/usr/sbin/crm configure show colocation ${name} > /dev/null 2&>1",
			}
		} else {
			exec { "Create colocation ${name} between ${resource1_name} and ${resource2_name} with score of ${score}":
				command => "/usr/sbin/crm configure colocation ${name} ${score}: ${resource1} ${resource2}",
				unless  => "/usr/sbin/crm configure show colocation ${name} > /dev/null 2>&1",
			}
		}
	}
}
