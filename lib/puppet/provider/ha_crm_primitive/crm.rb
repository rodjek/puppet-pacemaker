require 'rexml/document'

Puppet::Type.type(:ha_crm_primitive).provide(:crm) do
    desc "CRM shell support"

    commands :crm => "crm"
    commands :crm_resource => "crm_resource"

    def create
        crm "configure", "primitive", resource[:id], "#{resource[:class]}:#{resource[:type]}"
    end

    def destroy
        crm "configure", "delete", resource[:id]
    end

    def exists?
        cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
        resource = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']")

        !resource.nil?
    end

    def priority
        cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
        nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='priority']")
        if nvpair.nil?
            :absent
        else
            nvpair.attribute(:value).value
        end
    end

    def priority=(value)
        if value == "0"
            crm_resource "-m", "-r", resource[:id], "-d", "priority"
        else
            crm_resource "-m", "-r", resource[:id], "-p", "priority", "-v", value
        end
    end

    def target_role
        cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
        nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='target-role']")
        if nvpair.nil?
            :absent
        else
            nvpair.attribute(:value).value
        end
    end

    def target_role=(value)
        if value == :started
            crm_resource "-m", "-r", resource[:id], "-d", "target-role"
        else
            crm_resource "-m", "-r", resource[:id], "-p", "target-role", "-v", value.to_s.capitalize
        end
    end
end
