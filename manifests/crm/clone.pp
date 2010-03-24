define ha::crm::clone($resource, $clone_max="", $clone_node_max="", $globally_unique="",
        $ha_notify="", $ordered="", $interleave="", $ignore_dc="false", $priority="",
        $target_role="", $is_managed="", $ensure = present) {
    
    # Sanity checking
    $clone_name = "Ha::Crm::Clone[\"${name}\"]"
    if !($clone_max =~ /\d+/) and ($clone_max != "") {
        fail("Invalid clone_max passed to ${clone_name}: Value must be an integer")
    }

    if !($clone_node_max =~ /\d+/) and ($clone_node_max != "") {
        fail("Invalid clone_node_max passed to ${clone_name}: Value must be an integer")
    }

    if !($ha_notify =~ /(true|false)/) and ($ha_notify != "") {
        fail("Invalid ha_notify passed to ${clone_name}: Value must be either true or false")
    }

    if !($globally_unique =~ /(true|false)/) and ($globally_unique != "") {
        fail("Invalid globally_unique passed to ${clone_name}: Value must be either true or false")
    }

    if !($ordered =~ /(true|false)/) and ($ordered != "") {
        fail("Invalid ordered passed to ${clone_name}: Value must be either true or false")
    }

    if !($interleave =~ /(true|false)/) and ($interleave != "") {
        fail("Invalid interleave passed to ${clone_name}: Value must be either true or false")
    }
    
    if !($priority =~ /\d+/) and ($priority != "") {
        fail("Invalid priority passed to ${clone_name}: Value must be an integer")
    }

    if !($target_role =~ /(Started|Stopped|Master)/) and ($target_role != "") {
        fail("Invalid target_role passed to ${clone_name}: Value must be either Started, Stopped or Master")
    }

    if !($is_managed =~ /(true|false)/) and ($is_managed != "") {
        fail("Invalid is_managed passed to ${clone_name}: Value must be either true or false")
    }

    if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
        if($ensure == absent) {
            exec { "Deleting clone ${name}":
                command => "/usr/sbin/crm configure delete ${name}",
                onlyif  => "/usr/sbin/crm configure show clone ${name} > /dev/null 2>&1",
            }
        } else {
            exec { "Creating clone ${name} of resource ${resource}":
                command => "/usr/sbin/crm configure clone ${name} ${resource}",
                unless  => "/usr/sbin/crm_resource -r ${name} -q > /dev/null 2>&1",
                alias   => "clone-${name}",
            }

            ha::metaparameter { 
                "${name}-clone-max":
                    resource  => $name,
                    parameter => "clone-max",
                    value     => $clone_max,
                    require   => Exec["clone-${name}"],
                    ignore_dc => $ignore_dc,
                    ensure    => $clone_max ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-clone-node-max":
                    resource  => $name,
                    parameter => "clone-node-max",
                    value     => $clone_node_max,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $clone_node_max ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-globally-unique":
                    resource  => $name,
                    parameter => "globally-unique",
                    value     => $globally_unique,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $globally_unique ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-notify":
                    resource  => $name,
                    parameter => "notify",
                    value     => $ha_notify,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $ha_notify ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-ordered":
                    resource  => $name,
                    parameter => "ordered",
                    value     => $ordered,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $ordered ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-interleave":
                    resource  => $name,
                    parameter => "interleave",
                    value     => $interleave,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $interleave ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-priority":
                    resource  => $name,
                    parameter => "priority",
                    value     => $priority,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $priority ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-target_role":
                    resource  => $name,
                    parameter => "target-role",
                    value     => $target_role,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $target_role ? {
                        ""      => absent,
                        default => present,
                    };
                "${name}-is_managed":
                    resource  => $name,
                    parameter => "is-managed",
                    value     => $is_managed,
                    ignore_dc => $ignore_dc,
                    require   => Exec["clone-${name}"],
                    ensure    => $is_managed ? {
                        ""      => absent,
                        default => present,
                    };
            }
        }
    }
}
