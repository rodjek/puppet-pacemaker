define ha::crm::location($ensure=present, $resource, $score, $rule = '', $host = '', $ignore_dc="false") {
	if $rule == '' and $host == '' {
		fail("Must specify one of rule or host in Ha::Crm::Location[${name}]")
	}
	if $rule != '' and $host != '' {
		fail("Only one of rule and host can be specified in Ha::Crm::Location[${name}]")
	}
	
	if $rule == '' {
		$loc = "${score}: ${host}"
	} else {
		$loc = "rule ${score}: ${rule}"
	}
	
	if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
		if($ensure == absent) {
			exec { "Removing location rule ${name}":
				command => "/usr/sbin/crm configure location delete ${name}",
				onlyif  => "/usr/sbin/crm configure show location ${name} > /dev/null 2>&1",
			}
		} else {
			exec { "Creating location rule ${name}":
				command => "/usr/sbin/crm configure location ${name} ${resource} ${loc}",
				unless  => "/usr/sbin/crm configure show location ${name} > /dev/null 2>&1",
			}
		}
	}
}
