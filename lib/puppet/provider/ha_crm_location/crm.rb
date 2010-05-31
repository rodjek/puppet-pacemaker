require 'rexml/document'

Puppet::Type.type(:ha_crm_location).provide(:crm) do

	commands :crm => "crm"

	def create
    if resource[:rule]
      loc = "rule #{resource[:score]}: #{resource[:rule]}"
    else
      loc = "#{resource[:score]}: #{resource[:node]}"
    end

		crm "-F", "configure", "location", resource[:id], resource[:resource], loc
	end

	def destroy
		crm "-F", "configure", "delete", resource[:id]
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      resource[:ensure] == :present ? true : false
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			colocation = REXML::XPath.first(cib, "//rsc_location[@id='#{resource[:id]}']")

      if colocation.nil?
        false
      else
        true
      end
		end
	end
end
