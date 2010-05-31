Puppet::Type.newtype(:ha_crm_order) do
  @desc = "Manages Pacemaker resource ordering constraints."

  ensurable

  newparam(:id) do
    desc "A unique name for the order constraint"

    isnamevar
  end

  newparam(:first) do
    desc "The name of the resource that must be started before the `then`
          resource is allowed to."
  end

  newparam(:first_action) do
    desc "An optional action that the `first` resource should perform."
  end

  newparam(:then) do
    desc "The name of the resource that must be started after the `first`
          resource."
  end

  newparam(:then_action) do
    desc "An optional action that the `then` resource should perform."
  end

  newparam(:score) do
    desc "If greater than 0, the constraint is mandatory.  Otherwise it is 
          only a suggestion.  If absent, it will default to infinity (inf)."
    newvalues(:inf, /-?\d+/)
    defaultto(:inf)
  end

  newparam(:symmetrical) do
    desc "If true, stop the resources in the reverse order.  If absent, it
          will default to true."
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:only_run_on_dc, :boolean => true) do
    desc "In order to prevent race conditions, we generally only want to
          make changes to the CIB on a single machine (in this case, the
          Designated Controller)."

    newvalues(:true, :false)
    defaultto(:true)
  end

  validate do
    raise Puppet::Error, "You must specify a first resource (first)" unless @parameters.include?(:first)
    raise Puppet::Error, "You must specify a second resource (then)" unless @parameters.include(:then)
    raise Puppet::Error, "You must specify a score" unless @parameters.include?(:score)
  end
end
