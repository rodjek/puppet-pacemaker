import "primitive.pp"
import "stonith.pp"
import "ip.pp"

define ha::authkey($method, $key="") {
    if($method == "crc") {
        $changes = ["set ${name}/method ${method}"]
    } else {
        $changes = ["set ${name}/method ${method}", "set ${name}/key ${key}"]
    }

    augeas { "Setting /etc/ha.d/authkeys/${name}":
        changes => $changes,
        context => "/files/etc/ha.d/authkeys",
    }
}

define ha::node($autojoin="any", $use_logd="on", $compression="bz2",
                $keepalive="1", $warntime="5", $deadtime="10", $initdead="60", $authkey,
                $alert_email_address) {

    Augeas { context => "/files/etc/ha.d/ha.cf" }

    $email_content = "Heartbeat config on ${fqdn} has changed."

	case $operatingsystem {
		RedHat,CentOS: {
			case $operatingsystemrelease {
				5: {
                    package {
                        "pacemaker":
                            ensure  => "1.0.4-23.1",
                            require => Package["heartbeat"];
                        "heartbeat":
                            ensure => "2.99.2-8.1";
                    }
                }
            }
        }
		Debian,Ubuntu: {
            package {
                "pacemaker":
                    ensure  => "1.0.4-1.1anchor",
                    require => Package["heartbeat"];
                "heartbeat":
                    ensure => "2.99.2+sles11r9-1.1anchor";
                "openais":
                    ensure => purged;
            }
        }
    }

	case $operatingsystem {
        # RHEL packages have this service bundled in with the heartbeat
        # packages.
		Debian,Ubuntu: {
            service {
                "logd":
                    ensure    => running,
                    hasstatus => true,
                    enable    => true,
                    require   => [Package["pacemaker"], Package["heartbeat"]];
            }
        }
    }
    service {
        "heartbeat":
            ensure    => running,
            hasstatus => true,
            enable    => true,
            require   => [Package["pacemaker"], Package["heartbeat"]];
    }

	file {
		"/etc/ha.d/authkeys":
			ensure => present,
			mode   => 0600;

		# logd config, it's very simple and can be the same everywhere
		"/etc/logd.cf":
			ensure => present,
			mode   => 0440,
			owner  => "root",
			group  => "root",
			source => "puppet:///ha/etc/logd.cf";
        
        # Augeas lenses
        "/usr/share/augeas/lenses/hacf.aug":
            ensure => present,
            mode   => 0444,
            owner  => "root",
            group  => "root",
            source => "puppet:///ha/usr/share/augeas/lenses/hacf.aug";
        "/usr/share/augeas/lenses/haauthkeys.aug":
            ensure => present,
            mode   => 0444,
            owner  => "root",
            group  => "root",
            source => "puppet:///ha/usr/share/augeas/lenses/haauthkeys.aug";
	}

    augeas {
        "Setting /files/etc/ha.d/ha.cf/port":
            notify  => Exec["restart-email"],
            changes => "set udpport 694";
        "Setting /files/etc/ha.d/ha.cf/autojoin":
            notify  => Exec["restart-email"],
            changes => "set autojoin ${autojoin}";
        "Setting /files/etc/ha.d/ha.cf/use_logd":
            notify  => Exec["restart-email"],
            changes => "set use_logd ${use_logd}";
        "Setting /files/etc/ha.d/ha.cf/traditional_compression":
            notify  => Exec["restart-email"],
            changes => "set traditional_compression off";
        "Setting /files/etc/ha.d/ha.cf/compression":
            notify  => Exec["restart-email"],
            changes => "set compression ${compression}";
        "Setting /files/etc/ha.d/ha.cf/keepalive":
            notify  => Exec["restart-email"],
            changes => "set keepalive ${keepalive}";
        "Setting /files/etc/ha.d/ha.cf/warntime":
            notify  => Exec["restart-email"],
            changes => "set warntime ${warntime}";
        "Setting /files/etc/ha.d/ha.cf/deadtime":
            notify  => Exec["restart-email"],
            changes => "set deadtime ${deadtime}";
        "Setting /files/etc/ha.d/ha.cf/initdead":
            notify  => Exec["restart-email"],
            changes => "set initdead ${initdead}";
        "Setting /files/etc/ha.d/ha.cf/crm":
            notify  => Exec["restart-email"],
            changes => "set crm yes";
        "Setting /files/etc/ha.d/authkeys/auth":
            context => "/files/etc/ha.d/authkeys",
            changes => "set auth ${authkey}",
            before  => Ha::Authkey[$authkey],
            notify  => Exec["restart-email"];
    }

    exec { "Send restart email":
        alias       => "restart-email",
        command     => "/bin/echo \"${email_content}\" | /usr/bin/mail -s \"Heartbeat restart required\" ${alert_email_address}",
        refreshonly => true,
    }
}

define ha::mcast($group, $port=694, $ttl=1) {
	augeas { "Configure multicast group on ${name}":
		context => "/files/etc/ha.d/ha.cf",
		changes => [
		            "set mcast[last()+1]/interface ${name}",
		            "set mcast[last()]/group ${group}",
		            "set mcast[last()]/port ${port}",
		            "set mcast[last()]/ttl ${ttl}",
		           ],
		onlyif  => "match mcast/interface[.='${name}'] size == 0",
	}
	
	augeas { "Disable broadcast on ${name}":
		context => "/files/etc/ha.d/ha.cf",
		changes => "rm bcast"
	}
}
