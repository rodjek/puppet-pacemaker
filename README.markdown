# Overview

This module will allows us to automagically configure HA 
environments using Heartbeat2 & Pacemaker.  I would strongly recommend reading
http://clusterlabs.org/mediawiki/images/f/fb/Configuration_Explained.pdf
before continuing.

You really shouldn't use this module unless you know what you're doing.  Please
ensure that you run puppetd with --noop after committing any changes to live
setups.

If you attempt to use this module without having grokked the Configuration 
Explained PDF linked above and then complain about not understanding it (or
worse, break a live system), I will print out a copy of said manual and give
you a paper cut for each of it's 136 pages.  You have been warned!


# Cluster Setup

    ha::node { "<something>":
        authkey          => "<ha::authkey index>",
        autojoin         => "<autojoin setting (default: any)>", 
        use_logd         => "<on|off (default: on)>",
        compression      => "<compression method (default: bz2)>",
        keepalive        => "<seconds (default: 1)>", 
        warntime         => "<seconds (default: 6)>", 
        deadtime         => "<seconds (default: 10)>", 
        initdead         => "<seconds (default: 60)>", 

    ha::authkey { "<index>":
        method  => "<md5|sha1|crc>",
        key     => "<key> (not required for crc)",
        require => Ha::Node["<something>"],
    }

    ha::mcast { "<interface name>":
        group   => "<mcast group>",
        port    => "<mcast port> (default: 694)",
        ttl     => "<mcast ttl> (default: 1)",
        require => Ha::Node["<something>"],
    }

# Resource Management

There are two ways to manage resources in the ha module -- either the easy
way, with special types customised to common situations, or by directly
manipulating the primitives and properties (and such) of pacemaker.  The
former is much easier, but requires that someone has already written an
appropriate type, whilst the latter requires a lot more knowledge of how
pacemaker works, but lets you do anything you want.


## ha_crm_property

Set a cluster-wide (crm_config) property.

    ha_crm_property { "<property name>":
        value          => "<value>",
        ensure         => "(present|absent)",
        only_run_on_dc => "(true|false)",
    }

### Example:
    
    ha::property { "stonith-enabled":
        value  => "true",
        ensure => present,
    }

### Required Parameters:

* __namevar:__ The name of the property
* __value:__   The value of the property
* __ensure:__  Whether this property should exist in the CIB

### Optional Parameters:

* __only_run_on_dc:__ Should Puppet only attempt to manage this resource
                      if the node is the cluster DC (default: true)

## ha_crm_primitive

Create a primitive (resource).  In almost all cases, this resource will 
require additional parameters (ha_crm_parameter) in order to function correctly.

    ha_crm_primitive { "<primitive name>":
        type                => "<class>:<provider>:<type>"
        ensure              => "(present|absent)",
        only_run_on_dc      => "(true|false)",
        priority            => "<integer>",
        target_role         => "(stopped|started|master)",
        is_managed          => "(true|false)",
        resource_stickiness => "<integer>",
        migration_threshold => "<integer>",
        failure_timeout     => "<integer>",
        multiple_active     => "(block|stop_only|stop_start)",
    }

### Example:

    ha_crm_primitive { "fs_mysql":
        type   => "ocf:heartbeat:Filesystem",
        ensure => present,
    }

### Required Parameters:

* __namevar:__ The name of the primitive (used as a reference for most other ha:: types)
* __type:__ The primitive class (almost always will start with ocf: or lsb:)
* __ensure:__ Whether this primitive should exist in the CIB

### Optional Parameters:

* __only_run_on_dc:__ Should Puppet only attempt to manage this resource if the node is the cluster DC (default: true)
* __priority:__ The priority of the resource
* __target_role:__ What state should the cluster attempt to keep this resource in?
* __is_managed:__ Is the cluster allowed to start and stop the resource?
* __resource_stickiness:__ How much does the resource prefer to stay where it is?
* __migration_threshold:__ How many failures should occur for this resource on a node
                           before making the node ineligible to host this resource.
*__failure_timeout:__ How many seconds to wait before acting as if the failure had not occurred
*__multiple_active:__ What should the cluster do if it ever finds the resource active on more than one node
