Puppet::Type.newtype(:ha_crm_property) do
	@desc = "Set the cluster (crm_config) options"

	ensurable

	newparam(:name) do
		desc "The name of the property"

		isnamevar
	end

	newparam(:value) do
		desc "The value of the property"
	end

	newparam(:only_run_on_dc, :boolean => true) do
		desc "In order to prevent race conditions, we generally only want to
					make changes to the CIB on a single machine (in this case, the
					Designated Controller)."

		newvalues(:true, :false)
		defaultto(:true)
	end
end
