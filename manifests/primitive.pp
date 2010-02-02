define ha::primitive($class_name, $ensure=present, $monitor_interval, $ignore_dc="false", $stickiness="undef") {
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

define ha::parameter($resource, $parameter, $value, $ensure=present, $ignore_dc="false") {
    if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
        ha::resetstate { "${resource}-${parameter}":
            resource => $resource,
        }

        if($ensure == absent) {
            exec { "Removing ${parameter} from ${resource}":
                command => "/usr/sbin/crm_resource -r ${resource} -d ${parameter}",
                onlyif  => "/usr/sbin/crm_resource -r ${resource} -g ${parameter} > /dev/null 2>&1",
            }
        } else {
            exec { "Setting ${parameter} on ${resource} to ${value}":
                command => "/usr/sbin/crm_resource -r ${resource} -p ${parameter} -v \"${value}\"",
                unless  => "/usr/bin/test `/usr/sbin/crm_resource -r ${resource} -g ${parameter}` = \"${value}\"",
                notify  => Ha::Resetstate["${resource}-${parameter}"],
            }
        }
    }
}

define ha::metaparameter($resource, $parameter, $value, $ensure=present, $ignore_dc="false") {
    if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
        if($ensure == absent) {
            exec { "Removing ${parameter} from ${resource}":
                command => "/usr/sbin/crm_resource --meta -r ${resource} -d ${parameter}",
                onlyif  => "/usr/sbin/crm_resource --meta -r ${resource} -g ${parameter} > /dev/null 2>&1",
            }
        } else {
            exec { "Setting ${parameter} on ${resource} to ${value}":
                command => "/usr/sbin/crm_resource --meta -r ${resource} -p ${parameter} -v \"${value}\"",
                unless  => "/usr/bin/test `/usr/sbin/crm_resource --meta -r ${resource} -g ${parameter}` = \"${value}\"",
            }
        }
    }
}

define ha::ms($primitive, $master_max, $master_node_max, $clone_max, $clone_node_max, $ha_notify) {
    if($ha_cluster_dc == $fqdn) {
        exec { "Creating master ${name} for primitive ${primitive}":
            command => "/usr/sbin/crm configure ms ${name} ${primitive}",
            unless  => "/usr/sbin/crm_resource -r ${name} -q > /dev/null 2>&1",
        }

        ha::metaparameter {
            "${primitive}-master-max":
                resource  => $name,
                parameter => "master-max",
                value     => $master_max,
                notify    => Ha::Resetstate[$name],
                require   => Exec["Creating master ${name} for primitive ${primitive}"];
            "${primitive}-master-node-max":
                resource  => $name,
                parameter => "master-node-max",
                value     => $master_node_max,
                notify    => Ha::Resetstate[$name],
                require   => Exec["Creating master ${name} for primitive ${primitive}"];
            "${primitive}-clone-max":
                resource  => $name,
                parameter => "clone-max",
                value     => $clone_max,
                notify    => Ha::Resetstate[$name],
                require   => Exec["Creating master ${name} for primitive ${primitive}"];
            "${primitive}-clone-node-max":
                resource  => $name,
                parameter => "clone-node-max",
                value     => $clone_node_max,
                notify    => Ha::Resetstate[$name],
                require   => Exec["Creating master ${name} for primitive ${primitive}"];
            "${primitive}-notify":
                resource  => $name,
                parameter => "notify",
                value     => $ha_notify,
                notify    => Ha::Resetstate[$name],
                require   => Exec["Creating master ${name} for primitive ${primitive}"];
        }

        ha::resetstate { $name:
            resource => $name;
        }
    }
}

define ha::clone($resource, $clone_max="undef", $clone_node_max="1", $globally_unique="true",
		$ha_notify="false", $ordered="false", $interleave="false", $ignore_dc="false") {
	if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
		exec { "Creating clone ${name} of resource ${resource}":
			command => "/usr/sbin/crm configure clone ${name} ${resource}",
			unless  => "/usr/sbin/crm_resource -r ${name} -q > /dev/null 2>&1",
			alias   => "clone-${name}",
		}

		if($clone_max != "undef") {
			ha::metaparameter {	"${name}-clone-max":
				resource  => $name,
				parameter => "clone-max",
				value     => $clone_max,
				notify    => Ha::Resetstate[$name],
				require   => Exec["clone-${name}"],
				ignore_dc => $ignore_dc,
			}
		}

		ha::metaparameter { 
			"${name}-clone-node-max":
				resource  => $name,
				parameter => "clone-node-max",
				value     => $clone_node_max,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-globally-unique":
				resource  => $name,
				parameter => "globally-unique",
				value     => $globally_unique,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-notify":
				resource  => $name,
				parameter => "notify",
				value     => $ha_notify,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-ordered":
				resource  => $name,
				parameter => "ordered",
				value     => $ordered,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-interleave":
				resource  => $name,
				parameter => "interleave",
				value     => $interleave,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
		}

		ha::resetstate { $name:
			resource => $name,
		}
	}
}

define ha::group($members) {
    if($ha_cluster_dc == $fqdn) {
        $group_members = join_array_with_spaces($members)

        exec { "Creating group ${name} with the following members: ${group_members}":
            command => "/usr/sbin/crm configure group ${name} ${group_members}",
            unless  => "/usr/sbin/crm_resource -r ${name} -q > /dev/null 2>&1",    
        }
    }
}

define ha::colocation($score, $resource1_name, $resource1_role = "undef", $resource2_name, $resource2_role = "undef", $ensure = present) {
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

define ha::property($value) {
    if($ha_cluster_dc == $fqdn) {
        exec { "Setting CRM property ${name} to ${value}":
            command => "/usr/sbin/crm_attribute -n ${name} -v ${value}",
            unless  => "/usr/bin/test `/usr/sbin/crm_attribute -t crm_config -n ${name} -G -Q` = \"${value}\"",
        }
    }
}

define ha::order($score, $first_name, $first_action="undef", $then_name, $then_action="undef", $ensure = present) {
	if($ha_cluster_dc == $fqdn) {
		if($first_action != "undef") {
			$first = "${first_name}:${first_action}"
		} else {
			$first = $first_name
		}

		if($then_action != "undef") {
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

define ha::resetstate($resource) {
    if($ha_cluster_dc == $fqdn) {
        exec { "Reseting state for resource ${name}":
            command     => "/usr/sbin/crm resource cleanup ${resource} > /dev/null",
            refreshonly => true,
			returns     => 1,
        }
    }
}

define ha::location($ensure=present, $resource, $score, $rule = '', $host = '', $ignore_dc="false") {
	if $rule == '' and $host == '' {
		fail("Must specify one of rule or host in Ha::Location[${name}]")
	}
	if $rule != '' and $host != '' {
		fail("Only one of rule and host can be specified in Ha::Location[${name}]")
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
