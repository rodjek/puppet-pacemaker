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

    newproperty(:priority) do
        desc "The priority of the resource"

        defaultto "0"        
    end

    newproperty(:target_role) do
        desc "What state should the cluster attempt to keep this resource in?
        
              Allowed values:
                * stopped - Force the resource not to run
                * started - Allow the resource to be started
                * master -  Allow the resource to be started and promoted to Master"

        newvalues(:stopped, :started, :master)
        defaultto :started
    end

    newproperty(:is_managed) do
        desc "Is the cluster allowed to start and stop the resource?"

        newvalues(:true, :false)
        defaultto :true
    end

    newproperty(:resource_stickiness) do
        desc "How much does the resource prefer to stay where it is?

              This defaults to 'inherited', which is the value of 
              resource-stickiness in the rsc_defaults section"

        newvalues(:inherited, /\d+/)
        defaultto :inherited
    end

    validate do
        raise Puppet::Error, "You must specify a class for this primitive" unless @parameters.include?(:class)
        raise Puppet::Error, "You must specify a type for this primitive" unless @parameters.include?(:type)
    end
end
