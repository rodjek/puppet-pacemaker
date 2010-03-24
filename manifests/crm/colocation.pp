define ha::crm::colocation($score, $resource1_name, $resource1_role = "undef", $resource2_name, $resource2_role = "undef", $ensure = present) {
	if($ha_cluster_dc == $fqdn) {
		if($resource1_role != "undef") {
			$resource1 = "${resource1_name}:${resource1_role}"
		} else {
			$resource1 = $resource1_name
		}

		if($resource2_role != "undef") {
			$resource2 = "${resource2_name}:${resource2_role}"
		} else {
			$resource2 = $resource2_name
		}

		if($ensure == absent) {
			exec { "Removing colocation constraint ${name}":
				command => "/usr/sbin/crm configure delete ${name}",
				onlyif  => "/usr/sbin/crm configure show | grep ${name}",
			}
		} else {
			exec { "Create colocation ${name} between ${resource1_name} and ${resource2_name} with score of ${score}":
				command => "/usr/sbin/crm configure colocation ${name} ${score}: ${resource1} ${resource2}",
				unless  => "/usr/sbin/crm_resource -r ${resource1_name} -a  | grep ${name} > /dev/null 2>&1",
			}
		}
	}
}
