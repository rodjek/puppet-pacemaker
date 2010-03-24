define ha::crm::ms($primitive, $master_max, $master_node_max, $clone_max, $clone_node_max, $ha_notify) {
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
