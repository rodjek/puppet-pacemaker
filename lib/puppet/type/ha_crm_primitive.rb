Puppet::Type.newtype(:ha_crm_primitive) do
	# TODO
	#
	# * Set the default ensure value to true

	@doc = "Manage Pacemaker primitives (cluster resources)"

	ensurable

	newparam(:type) do
		desc "The name of the Resource Agent you with to use. eg ocf:heartbeat:IPaddr"
	end

	newparam(:id) do
		desc "The name of the resource"

		isnamevar
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

	newproperty(:resource_stickiness) do
		desc "How much does the resource prefer to stay where it is?

					This defaults to 'inherited', which is the value of 
					resource-stickiness in the rsc_defaults section"

		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:migration_threshold) do
		desc "How many failures should occur for this resource on a node
					before making the node ineligible to host this resource."

		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:failure_timeout) do
		desc "How many seconds to wait before acting as if the failure had
					not occurred (and potentially allowing the resource back to the
					node on which it failed."
    
		newvalues(:absent, /\d+/)
		defaultto :absent
	end

	newproperty(:multiple_active) do
		desc "What should the cluster do if it ever finds the resource active
					on more than one node.

					Allowed values:
						* block      - Mark the resource as unmanaged
						* stop_only  - Stop all active instances and leave them that way
						* stop_start - Stop all active instances and start the resource
													 in one location only."
    
		newvalues(:absent, :block, :stop_only, :stop_start)
		defaultto :absent
	end

	validate do
		raise Puppet::Error, "You must specify a type for this primitive" unless @parameters.include?(:type)
	end
end
