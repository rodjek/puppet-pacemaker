require 'rexml/document'

Puppet::Type.type(:ha_crm_primitive).provide(:crm) do
    desc "CRM shell support"

    commands :crm => "crm"

    def create
        crm "configure", "primitive", resource[:id], "#{resource[:class]}:#{resource[:type]}"
    end

    def destroy
        crm "configure", "delete", resource[:id]
    end

    def exists?
        cib_file = File.open("/var/lib/heartbeat/crm/cib.xml")
        cib = REXML::Document.new cib_file
        
        resource = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']")

        !resource.nil?
    end
end
