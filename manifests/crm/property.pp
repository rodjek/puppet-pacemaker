define ha::crm::property($value, $type='crm_config', $ensure=present) {
    if($type !~ /(crm_config|rsc_defaults|op_defaults)/) {
        fail("Unknown property type '${type}' passed to ha::crm::property")
    }

    if($ha_cluster_dc == $fqdn) {
        if($ensure == absent) {
            exec { "Deleting CRM property ${name}":
                command => "/usr/sbin/crm_attribute -t ${type} -n ${name} -D",
                onlyif  => "/usr/sbin/crm_attribute -t ${type} -n ${name} -G -Q",
            }
        } else {
            exec { "Setting CRM property ${name} to ${value}":
                command => "/usr/sbin/crm_attribute -t ${type} -n ${name} -v ${value}",
                unless  => "/usr/bin/test `/usr/sbin/crm_attribute -t ${type} -n ${name} -G -Q` = \"${value}\"",
            }
        }
    }
}
