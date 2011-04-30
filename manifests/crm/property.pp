# Public: Manage cluster properties/attributes.
# 
# namevar - The String name of the property.
# value   - The String value of the property.
# type    - The String type of the property to be set.  Valid values are
#           crm_config, rsc_defaults and op_defaults (default: crm_config).
# ensure  - The String desired state of the property.  Valid values are
#           present and absent (default: present).
#
# Examples
#
#   # Enable STONITH on a cluster
#   ha::crm::property { 'stonith-enabled':
#     value => 'true',
#   }
#
#   # Set a default stickiness value for all resources in inherit
#   ha::crm::property { 'resource-stickiness':
#     value => '100',
#     type  => 'rsc_defaults',
#   }
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
