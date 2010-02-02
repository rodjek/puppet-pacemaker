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


## ha::property

Set a cluster-wide property.

    ha::property { "<property name>":
        value => "<value>",
    }

### Example:
    
    ha::property { "stonith-enabled":
        value => "true",
    }

Parameters:
* namevar: The name of the property
* value:   The value of the property


## ha::ip

Create an IP that floats around the cluster.  The resource name will be
"ha-ip-<ip address>" (which is important when you want to co-locate it with
the service(s) that use it).

### Example:

    ha::ip { faff: address => "192.168.0.1" }

Parameters:

* namevar: Unimportant.
* address: The IP address to float.


## ha::primitive

Create a primitive (resource).  In almost all cases, this resource will 
require additional parameters (ha::parameter and/or ha::metaparameter) in 
order to function correctly.

    ha::primitive { "<primitive name>":
        monitor_interval => "<time period>",
        class_name       => "<class name>",
    }

### Example:

    ha::primitive { "fs_mysql":
        class_name       => "ocf:heartbeat:Filesystem",
        monitor_interval => "10s",
    }

Parameters:

* namevar:          The name of the primitive (used as a reference for most 
                    other ha:: types)
* monitor_interval: How often to check the health of the primitive
* class_name:       The primitive class (almost always will start with ocf:
                      or lsb:)


##ha::parameter

Set a parameter on a defined primitive.  Parameters are used to tell Pacemaker
how to configure the primitive (i.e. what the filesystem is for a floating
filesystem).

    ha::parameter { "<some unique string>":
        resource  => "<resource name>",
        parameter => "<parameter name>",
        value     => "<value>",
    }

### Example:
    
    ha::parameter { "fs_mysql-fstype":
        resource  => "fs_mysql",
        parameter => "fstype",
        value     => "ext3",
    }

Parameters:
    
* namevar:   Unimportant
* resource:  The namevar of the ha::primitive that you want to apply the parameter to.
* parameter: The name of the parameter.
* value:     The value of the parameter.


## ha::metaparameter

Set a metaparameter on a defined primitive.  Metaparameters are used to tell
Pacemaker how to handle the resource (i.e. is the resource managed).

    ha::metaparameter { "<some unique string>":
        resource  => "<resource name>",
        parameter => "<parameter name>",
        value     => "<value>",
    }

### Example:
    
    ha::metaparameter { "fs_mysql-is-managed":
        resource  => "fs_mysql",
        parameter => "is-managed",
        value     => "false",
    }

Parameters:

* namevar:   Unimportant
* resource:  The namevar of the ha::primitive that you want to apply the
                 metaparameter to.
* parameter: The name of the metaparameter.
* value:     The value of the metaparameter.


## ha::ms

Configure a multi-state resource (stateful cloned resource).

    ha::ms { "<resource name>":
        primitive       => "<primitive name>",
        master_max      => "<integer>",
        master_node_max => "<integer>",
        clone_max       => "<integer>",
        clone_node_max  => "<integer>",
        ha_notify       => "<true|false>",
    }

### Example:

    ha::ms { "ms_drbd_mysql":
        primitive       => "drbd_mysql",
        master_max      => "1",
        master_node_max => "1",
        clone_max       => "2",
        clone_node_max  => "1",
        ha_notify       => "true",
    }

Parameters:

* namevar:         Unimportant
* primitive:       The namevar of the ha::primitive
* master-max:      How many copies of the resource can be promoted to 
                   Master.
* master-node-max: How many copies of the resource can be promoted to 
                       Master on a single node.
* clone_max:       How many copies of the resource to start.
* clone_node_max:  How many copies of the resource can be started on a 
                       single node.
* ha_notify:       Notify the other copies of the resource before and 
                       after any actions.
    

## ha::colocation

Places a resource relative to another resource.  This can be significantly
more complex than it sounds.  Please make sure that you are familiar with the
below document before proceeding (a misconfigured colocation constraint can
bring down a working cluster with ease).
http://oss.beekhof.net/~beekhof/heartbeat/docs/Colocation-Explained.pdf

    ha::colocation { "<namevar>"
        score          => "<integer>|inf|-inf",
        resource1_name => "<first resource name>",
        resource1_role => "<first resource role (optional)>",
        resource2_name => "<second resource name>",
        resource2_role => "<second resource role (optional)>",
    }

### Example:

    ha::colocation { "fs_mysql_with_drbd_mysql":
        score          => "inf",
        resource1_name => "fs_mysql",
        resource2_name => "ms_drbd_mysql",
        resource2_role => "Master",
    }

Parameters:

* namevar:        A unique name for this colocation contstraint.
* score:          Positive values indicate the resources should run on the
                      same node, negative values indicate they should not.
* resource1_name: The name of the resource to be moved
* resource1_role: The role that the resource must be in (optional)
* resource2_name: The name of the target resource.
* resource2_role: The role that the resource must be in (optional)


## ha::order

Creates an order of operations for resources (i.e. promote a DRBD resource
to Master on a node before mounting the filesystem).

    ha::order {
        score        => "<integer>|inf|-inf",
        first_name   => "<first resource name>",
        first_action => "<first resource action (optional)>",
        then_name    => "<second resource name>",
        then_action  => "<second resource action (optional)>",
    }

### Example:

    ha::order {
        score        => "inf",
        first_name   => "ms_drbd_mysql",
        first_action => "promote",
        then_name    => "fs_mysql",
        then_action  => "start",
    }

Parameters:

* namevar:      A unique name for this ordering constraint.
* score:        Determines whether this ordering constraint is mandatory 
                    or only advisory
* first_name:   The name of the first resource
* first_action: The action to watch for on the first resource (optional)
* then_name:    The name of the second resource 
* then_action:  The action to initiate on the second resource (optional)


## ha::location

Decides which nodes a resource can run on.  You can either supply a rule or a
host in each location constraint, but not both.

    ha::location { "<namevar>":
        resource => "<resource name>",
        score    => "<score>",
        rule     => "<rule> (optional)",
        host     => "<node> (optional)",
    }

### Example:

    ha::location { "fs_mysql_on_db1":
        resource => "fs_mysql",
        score    => "200",
        host     => "db1",
    }

Parameters:

* namevar:  A unique name for this location contstraint.
* resource: The name of the resource that this constraint applies to.
* score:    Positive values indicate the resource can run on the node, 
                negative values indicate it can not.
* host:     The name of the node that this rule applies to (only if rule 
                not supplied). 
* rule:     A valid rule string (only if host is not supplied).


## ha::resetstate

This will cause Pacemaker to reset the state the specified resource (to
recover from any temporary errors.  This is particularly useful during the
initial setup of a cluster as Puppet will create primitives without any
parameters (which Pacemaker will try to bring up, causing errors).

    ha::resetstate { "<some unique string>":
        resource => "<name of resource to reset>",
    }

### Example:
    
    ha::resetstate { "reset-fs-mysql":
        resource => "fs_mysql",
    }

Parameters:
    
* namevar:  Unimportant
* resource: The namevar of the ha::primitive resource that you want to 
                reset


# Notes

 * Modifying the (meta)?parameters of a primitive/ms will trigger a reset of
   the state of the primitive/rs.
 * Not all features of heartbeat/pacemaker are currently supported in this
   module at this time.


# Realworld example (DRBD & filesystem)

In the following example, we'll configure:
* 2 nodes (ha::node) with STONITH disabled (ha::property)
 - ha1
 - ha2
* 2 HA resources (ha::primitive)
 - drbd_test (an existing DRBD device) with the following parameters
  * drbd-resource => "r0" (should match the resource name in your drbd.conf)
  * device => "/dev/drbd0" (should match the resource device in your drbd.conf)
 - fs_drbd_test (the DRBD device file system mount) with the following parameters
  * directory => "/mnt" (the location you want to mount the DRBD device to)
  * fstype => "ext3" (the filesystem on the DRBD device
* As the DRBD resource can be in multiple states while still being up (ie 
    Master/Slave), we can configure this resource with ha::ms to reflect this.
* We then want to ensure that both the DRBD device and the filesystem mount
    active on the same server (ha::colocation)
* We also want to ensure that the DRBD device is promoted to Master before
    attempting to mount it (ha::order)

## site.pp

    node ha1, ha2 {
        ha::node { "ha": }
            authkey => "1",
        }
    
        ha::authkey { "1":
            method => "sha1",
            key    => "fullofwin",
        }
    
        ha::mcast { ["eth0", "eth1"]:
            group => "255.0.0.50",
        }
    
        ha::property { "stonith-enabled":
            value    => "false",
            before   => Ha::Primitive["drbd_test"],
        }
    
        ha::primitive { 
            "drbd_test":
                monitor_interval => "10s",
                class_name       => "ocf:linbit:drbd";
            "fs_drbd_test":
                monitor_interval => "10s",
                class_name       => "ocf:heartbeat:Filesystem";
        }
    
        ha::parameter { 
            "drbd_test-drbd-resource":
                resource  => "drbd_test",
                parameter => "drbd-resource",
                value     => "r0",
                require   => Ha::Primitive["drbd_test"];
            "fs_drbd_test-device":
                resource  => "fs_drbd_test",
                parameter => "device",
                value     => "/dev/drbd0",
                require   => Ha::Primitive["fs_drbd_test"];
            "fs_drbd_test-directory":
                resource  => "fs_drbd_test",
                parameter => "directory",
                value     => "/mnt",
                require   => Ha::Primitive["fs_drbd_test"];
            "fs_drbd_test-fstype":
                resource  => "fs_drbd_test",
                parameter => "fstype",
                value     => "ext3",
                require   => Ha::Primitive["fs_drbd_test"];
        }
    
        ha::ms { "ms_drbd_test":
            primitive       => "drbd_test",
            master_max      => "1",
            master_node_max => "1", 
            clone_max       => "2", 
            clone_node_max  => "1", 
            ha_notify       => "true",
            require         => Ha::Primitive["drbd_test"],
        }
    
        ha::colocation { "fs_with_drbd":
            score          => "inf",
            resource1_name => "fs_drbd_test",
            resource2_name => "ms_drbd_test",
            resource2_role => "Master",
            require        => [Ha::Ms["ms_drbd_test"], Ha::Primitive["fs_drbd_test"]],
        }
        
        ha::order { "fs_after_drbd":
            score        => "inf",
            first_name   => "ms_drbd_test",
            first_action => "promote",
            then_name    => "fs_drbd_test",
            then_action  => "start",
            require      => [Ha::Ms["ms_drbd_test"], Ha::Primitive["fs_drbd_test"]],
        }
    }
