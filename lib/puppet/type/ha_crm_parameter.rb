Puppet::Type.newtype(:ha_crm_parameter) do
	@desc = ""

	ensurable

	newparam(:resource) do
		desc "The name of the resource that this parameter should be applied to"
	end

	newparam(:id) do
		desc "The ID of the resource-parameter combination.  A throwaway value."
		isnamevar
	end

	newparam(:name) do
		desc "The name of the parameter"
	end

	newparam(:value) do
		desc "The value of the parameter"
	end

	newparam(:meta) do
		desc "Should this parameter be a meta-parameter?"

		newvalues(:true, :false)
		defaultto :false
	end

  newparam(:only_run_on_dc) do
    desc "Should this resource only be actioned if the node is the cluster DC?"

    newvalues(:true, :false)
    defaultto :true
  end
end
