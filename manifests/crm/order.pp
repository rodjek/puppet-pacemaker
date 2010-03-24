define ha::crm::order($score, $first_name, $first_action="", $then_name, $then_action="", $ensure = present) {
	if($ha_cluster_dc == $fqdn) {
		if($first_action != "") {
			$first = "${first_name}:${first_action}"
		} else {
			$first = $first_name
		}

		if($then_action != "") {
			$then = "${then_name}:${then_action}"
		} else {
			$then = $then_name
		}

		if($ensure == absent) {
			exec { "Removing ordering constraint ${name}":
				command => "/usr/sbin/crm configure delete ${name}",
				onlyif  => "/usr/sbin/crm configure show | grep ${name}",
			}
		} else {
			exec { "Creating ordering contstraint ${name} between ${first_name} and ${then_name}":
				command => "/usr/sbin/crm configure order ${name} ${score}: ${first} ${then}",
				unless  => "/usr/sbin/crm configure show | grep ${name}",
			}
		}
	}
}
