define ha::ip($address, $stickiness="undef", $ensure = present) {
	ha::primitive { "ha-ip-${address}":
		class_name       => "ocf:heartbeat:IPaddr2",
		monitor_interval => "20",
		ensure           => $ensure,
		stickiness       => $stickiness,
	}
	
	if $ensure != absent {
		ha::parameter { "ha-ip-${address}-ip":
			resource  => "ha-ip-${address}",
			parameter => "ip",
			value     => $address,
			require   => Ha::Primitive["ha-ip-${address}"],
		}
	}
}

