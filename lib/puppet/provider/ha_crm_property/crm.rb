require 'rexml/document'

Puppet::Type.type(:ha_crm_property).provide(:crm) do

	commands :crm_attribute => "crm_attribute"

	def create
		crm_attribute "-t", "crm_config", "-n", resource[:name], "-v", resource[:value]
	end

	def destroy
		crm_attribute "-t", "crm_config", "-n", resource[:name], "-D"
	end

	def exists?
		if (resource[:only_run_on_dc] == :true) and (Facter.value(:ha_cluster_dc) != Facter.value(:fqdn))
			true
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			property = REXML::XPath.first(cib, "/cib/configuration/crm_config/cluster_property_set/nvpair[@name='#{resource[:name]}']")
			if property.nil?
				false
			else
				property.attribute(:value).value == resource[:value] ? true : false
			end
		end
	end
end
