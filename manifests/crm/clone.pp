define ha::crm::clone($resource, $clone_max="undef", $clone_node_max="1", $globally_unique="true",
		$ha_notify="false", $ordered="false", $interleave="false", $ignore_dc="false") {
	if($ha_cluster_dc == $fqdn) or ($ignore_dc == "true") {
		exec { "Creating clone ${name} of resource ${resource}":
			command => "/usr/sbin/crm configure clone ${name} ${resource}",
			unless  => "/usr/sbin/crm_resource -r ${name} -q > /dev/null 2>&1",
			alias   => "clone-${name}",
		}

		if($clone_max != "undef") {
			ha::metaparameter {	"${name}-clone-max":
				resource  => $name,
				parameter => "clone-max",
				value     => $clone_max,
				notify    => Ha::Resetstate[$name],
				require   => Exec["clone-${name}"],
				ignore_dc => $ignore_dc,
			}
		}

		ha::metaparameter { 
			"${name}-clone-node-max":
				resource  => $name,
				parameter => "clone-node-max",
				value     => $clone_node_max,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-globally-unique":
				resource  => $name,
				parameter => "globally-unique",
				value     => $globally_unique,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-notify":
				resource  => $name,
				parameter => "notify",
				value     => $ha_notify,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-ordered":
				resource  => $name,
				parameter => "ordered",
				value     => $ordered,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
			"${name}-interleave":
				resource  => $name,
				parameter => "interleave",
				value     => $interleave,
				notify    => Ha::Resetstate[$name],
				ignore_dc => $ignore_dc,
				require   => Exec["clone-${name}"];
		}

		ha::resetstate { $name:
			resource => $name,
		}
	}
}
