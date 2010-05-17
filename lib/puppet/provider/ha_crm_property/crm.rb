require 'rexml/document'

Puppet::Type.type(:ha_crm_property).provide(:crm) do

	command :crm_attribute => "crm_attribute"

	def create
		crm_attribute "-t", "crm_config", "-n", resource[:name], "-v", resource[:value]
	end

	def destroy
		crm_attribute "-t", "crm_config", "-n", resource[:name], "-D"
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:value]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			property = REXML::XPath(cib, "/cib/configuration/crm_config/cluster_property_set/nvpair[@name='#{resource[:name]}']")
			if property.nil?
				:absent
			else
				property.attribute(:value).value
			end
		end
	end
end
