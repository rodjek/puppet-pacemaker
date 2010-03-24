define ha::crm::primitive($resource_type, $ensure=present, $monitor_interval, $ignore_dc="false"
    $priority="", $target_role="", $is_managed="", $resource_stickiness="", $migration_threshold="",
    $failure_timeout="", $multiple_active="") {

    # Sanity checking inputs
    $primitive_name = "Ha::Crm::Primitive[\"${name}\"]"
    if !($priority =~ /\d+/) and ($priority != "") {
        fail("Invalid priority passed to ${primitive_name}: Value must be an integer")
    }

    if !($target_role =~ /(Stopped|Started|Master)/) and ($target_role != "") {
        fail("Invalid target_role passed to ${primitive_name}: Value must be either Started, Stopped or Master")
    }

    if !($is_managed =~ /(true|false)/) and ($is_managed != "") {
        fail("Invalid is_managed passed to ${primitive_name}: Value must be either true or false")
    }

    if !($resource_stickiness =~ /\d+/) and ($resource_stickiness != "") {
        fail("Invalid resource_stickiness passed to ${primitive_name}: Value must be an integer")
    }

    if !($migration_threshold =~ /\d+/) and ($migration_threshold != "") {
        fail("Invalid migration_threshold passed to ${primitive_name}: Value must be an integer")
    }

    if !($failure_timeout =~ /\d+/) and ($failure_timeout != "") {
        fail("Invalid failure_timeout passed to ${primitive_name}: Value must be an integer")
    }

    if !($multiple_active =~ /(block|stop_only|stop_start)/) and ($multiple_active != "") {
        fail("Invalid multiple_active passed to ${primitive_name}: Value must be either block, stop_only or stop_start")
    }

    if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
        if($ensure == absent) {
            exec { "Removing primitive ${name}":
                command => "/usr/sbin/crm_resource -D -r ${name} -t primitive",
                onlyif  => "/usr/sbin/crm_resource -r ${name} -t primitive -q > /dev/null 2>&1",
            }
        } else {
            exec { "Creating primitive ${name}":
                command => "/usr/sbin/crm configure primitive ${name} ${resource_type} op monitor interval=\"${monitor_interval}\"",
                unless  => "/usr/sbin/crm_resource -r ${name} -t primitive -q > /dev/null 2>&1",
            }

            if($priority != "") {
                ha::crm::metaparameter { "${name}-priority":
                    resource  => $name,
                    parameter => "priority",
                    value     => $priority,
                    require   => Exec["Creating primitive ${name}"],
                }
            }

            if($target_role != "") {
                ha::crm::metaparameter { "${name}-target_role":
                    resource  => $name,
                    parameter => "target-role",
                    value     => $target_role,
                    require   => Exec["Creating primitive ${name}"],
                }
            }
        
            if($is_managed != "") {
                ha::crm::metaparameter { "${name}-is_managed":
                    resource  => $name,
                    parameter => "is-managed",
                    value     => $is_managed,
                    require   => Exec["Creating primitive ${name}"],
                }
            }

			if($resource_stickiness != "") {
				ha::crm::metaparameter { "${name}-resource_stickiness":
					resource  => $name,
					parameter => "resource-stickiness",
					value     => $resource_stickiness,
					require   => Exec["Creating primitive ${name}"],
				}
			}

            if($migration_threshold != "") {
                ha::crm::metaparameter { "${name}-migration_threshold":
                    resource  => $name,
                    parameter => "migration-threshold",
                    value     => $migration_threshold,
                    require   => Exec["Creating primitive ${name}"],
                }
            }

            if($failure_timeout != "") {
                ha::crm::metaparameter { "${name}-failure_timeout":
                    resource  => $name,
                    parameter => "failure-timeout",
                    value     => $failure_timeout,
                    require   => Exec["Creating primitive ${name}"],
                }
            }

            if($multiple_active != "") {
                ha::crm::metaparameter { "${name}-mulitple_active":
                    resource  => $name,
                    parameter => "multiple-active",
                    value     => $multiple_active,
                    require   => Exec["Creating primitive ${name}"],
                }
            }
        }
    }
}
