Puppet::Type.newtype(:ha_crm_colocation) do
	@desc = "Manages Pacemaker resource colocation constraints."

	ensurable

	newparam(:id) do
		desc "A unique name for the colocation constraint"

		isnamevar
	end

	newparam(:resource) do
		desc "The colocation source.  If the constraint cannot be satisfied, the
          cluster may decide not to allow the resource to be run at all."
	end

  newparam(:resource_role) do
    desc "An optional role for the colocation source"
  end

  newparam(:with_resource) do
    desc "The colocation target.  The cluster will decide where to put this
          resource first and then decide where to put the resource in the
          resource field."
  end

  newparam(:with_resource_role) do
    desc "An optional role for the colocation target"
  end

  newparam(:score) do
    desc "Positive values indicate the resources SHOULD run on the same node.
          Negative values indicate the resources SHOULD NOT run on the same.
          Values of inf or -inf change SHOULD to MUST."
  end

	newparam(:only_run_on_dc, :boolean => true) do
		desc "In order to prevent race conditions, we generally only want to
					make changes to the CIB on a single machine (in this case, the
					Designated Controller)."

		newvalues(:true, :false)
		defaultto(:true)
	end

  validate do
    raise Puppet::Error, "You must specify a colocation source (resource)" unless @parameters.include?(:resource)
    raise Puppet::Error, "You must specify a colocation target (with_resource)" unless @parameters.include(:with_resource)
    raise Puppet::Error, "You must specify a score" unless @parameters.include?(:score)
  end
end
