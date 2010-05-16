Puppet::Type.newtype(:ha_crm_primitive) do
    @doc = "Manage Pacemaker primitives"

    ensureable

    newparam(:class) do
        desc "The standard that the script conforms to."

        newvalues(:heartbeat, :lsb, :ocf, :stonith)
    end

    newparam(:type) do
        desc "The name of the Resource Agent you with to use. eg. IPAddr or Filesystem"
    end

    newparam(:id) do
        desc "The name of the resource"

        isnamevar
    end

    validate do
        raise Puppet::Error, "You must specify a class for this primitive" unless @parameters.include?(:class)
        raise Puppet::Error, "You must specify a type for this primitive" unless @parameters.include?(:type)
    end
end
