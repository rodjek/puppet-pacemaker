define ha::crm::property($value, $ensure=present) {
    if($ha_cluster_dc == $fqdn) {
        if($ensure == absent) {
            exec { "Deleting CRM property ${name}":
                command => "/usr/sbin/crm_attribute -t crm_config -n ${name} -D",
                onlyif  => "/usr/sbin/crm_attribute -t crm_config -n ${name} -G -Q",
            }
        } else {
            exec { "Setting CRM property ${name} to ${value}":
                command => "/usr/sbin/crm_attribute -n ${name} -v ${value}",
                unless  => "/usr/bin/test `/usr/sbin/crm_attribute -t crm_config -n ${name} -G -Q` = \"${value}\"",
            }
        }
    }
}
