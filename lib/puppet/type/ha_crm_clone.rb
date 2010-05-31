Puppet::Type.newtype(:ha_crm_clone) do
	@doc = "Manage Pacemaker clones"

	ensurable

	newparam(:id) do
		desc "The name of the resource"

		isnamevar
	end

  newparam(:resource) do
    desc "The name of the cluster resource (primitive) that will be cloned"
  end

	newparam(:only_run_on_dc, :boolean => true) do
		desc "In order to prevent race conditions, we generally only want to
					make changes to the CIB on a single machine (in this case, the
					Designated Controller)."

		newvalues(:true, :false)
		defaultto(:true)
	end

	newproperty(:priority) do
		desc "The priority of the resource"

		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:target_role) do
		desc "What state should the cluster attempt to keep this resource in?
        
					Allowed values:
						* stopped - Force the resource not to run
						* started - Allow the resource to be started
						* master -  Allow the resource to be started and promoted to Master"

		newvalues(:absent, :stopped, :started, :master)
		defaultto :absent
	end

	newproperty(:is_managed) do
		desc "Is the cluster allowed to start and stop the resource?"

		newvalues(:absent, :true, :false)
		defaultto :absent
	end

	newproperty(:clone_max) do
		desc "How many copies of the resource to start.  If absent, will default
          to the number of nodes in the cluster."

		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:clone_node_max) do
		desc "How many copies of the resource can be started on a single node.
          If absent, defaults to 1."

		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:notify_clones) do
		desc "When stopping or starting a copy of the clone, tell all the other
          copies beforehand and when the cation was successful.  If absent,
          defaults to false."
    
		newvalues(:absent, :true, :false)
		defaultto :absent
	end

	newproperty(:globally_unique) do
		desc "Does each copy of the clone perform a different function?  If absent,
          defaults to true."
    
		newvalues(:absent, :true, :false)
		defaultto :absent
	end

  newproperty(:ordered) do
    desc "Should the copies be started in series (instead of in parallel).  If
          absent, defaults to false."

    newvalues(:absent, :true, :false)
    defaultto :absent
  end

  newproperty(:interleave) do
    desc "Changes the behavior of ordering constraints (between clones/masters)
          so that instances can start/stop as soon as their peer instance has
          (rather than waiting for every instance of the other clone has).  If
          absent, defaults to false."

    newvalues(:absent, :true, :false)
    defaultto :absent
  end

	validate do
		raise Puppet::Error, "You must specify the resource to be cloned" unless @parameters.include?(:resource)
	end
end
