Puppet::Type.newtype(:ha_crm_group) do
	@desc = "Manages Pacemaker resource groups."

	ensurable

	newparam(:id) do
		desc "A unique name for the group"

		isnamevar
	end

  newparam(:resources) do
    desc "Array of resources to group. They will be started in the order they are ordered in the array."
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

  validate do
    raise Puppet::Error, "You must specify a list of resources" unless @parameters.include?(:resources)
  end
end
