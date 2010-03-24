define ha::crm::metaparameter($resource, $parameter, $value, $ensure=present, $ignore_dc="false") {
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
