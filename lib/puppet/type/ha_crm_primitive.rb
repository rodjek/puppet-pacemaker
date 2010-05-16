Puppet::Type.newtype(:ha_crm_primitive) do
    @doc = "Manage Pacemaker primitives"

    ensureable

    newparam(:class) do
        desc "The standard that the script conforms to."

        validate do |value|
            unless value =~ /^(heartbeat|lsb|ocf|stonith)$/ do
                raise ArgumentError, "%s is not a valid Resource Agent class" % value
            end
        end
    end

    newparam(:type) do
        desc "The name of the Resource Agent you with to use. eg. IPAddr or Filesystem"
    end

    newparam(:id) do
        desc "The name of the resource"

        isnamevar
    end
end
