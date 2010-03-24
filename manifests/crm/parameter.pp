define ha::crm::parameter($resource, $parameter, $value, $ensure=present, $ignore_dc="false") {
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
