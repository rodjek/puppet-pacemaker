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

    newproperty(:migration_threshold) do
        desc "How many failures should occur for this resource on a node
              before making the node ineligible to host this resource."

        newvalues(/\d+/)
        defaultto "0"
    end

    newproperty(:failure_timeout) do
        desc "How many seconds to wait before acting as if the failure had
              not occurred (and potentially allowing the resource back to the
              node on which it failed."
    
        newvalues(/\d+/)
        defaultto "0"
    end

    newproperty(:multiple_active) do
        desc "What should the cluster do if it ever finds the resource active
              on more than one node.

              Allowed values:
                * block      - Mark the resource as unmanaged
                * stop_only  - Stop all active instances and leave them that way
                * stop_start - Stop all active instances and start the resource
                               in one location only."
    
        newvalues(:block, :stop_only, :stop_start)
        defaultto :stop_start
    end

    validate do
        raise Puppet::Error, "You must specify a class for this primitive" unless @parameters.include?(:class)
        raise Puppet::Error, "You must specify a type for this primitive" unless @parameters.include?(:type)
    end
end
