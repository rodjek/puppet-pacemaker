define ha::crm::property($value) {
    if($ha_cluster_dc == $fqdn) {
        exec { "Setting CRM property ${name} to ${value}":
            command => "/usr/sbin/crm_attribute -n ${name} -v ${value}",
            unless  => "/usr/bin/test `/usr/sbin/crm_attribute -t crm_config -n ${name} -G -Q` = \"${value}\"",
        }
    }
}
