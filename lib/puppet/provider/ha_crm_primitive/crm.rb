require 'rexml/document'

Puppet::Type.type(:ha_crm_primitive).provide(:crm) do
	desc "CRM shell support"

	commands :crm => "crm"
	commands :crm_resource => "crm_resource"

	def create
		crm "-F", "configure", "primitive", resource[:id], resource[:type]
	end

	def destroy
		crm "-F", "configure", "delete", resource[:id]
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:ensure] == :present ? true : false
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			primitive = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']")
			!primitive.nil?
		end
	end

	def priority
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:priority]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='priority']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def priority=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "priority"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "priority", "-v", value
		end
	end

	def target_role
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:target_role]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='target-role']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def target_role=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "target-role"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "target-role", "-v", value.to_s.capitalize
		end
	end

	def is_managed
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:is_managed]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='is-managed']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def is_managed=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "is-managed"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "is-managed", "-v", value.to_s
		end
	end

	def resource_stickiness
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:resource_stickiness]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='resource-stickiness']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def resource_stickiness=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "resource-stickiness"
		else
			crm_resource "-m", "-r", reosurce[:id], "-p", "resource-stickiness", "-v", value.to_s
		end
	end

	def migration_threshold
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:migration_threshold]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='migration-threshold']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def migration_threshold=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "migration-threshold"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "migration-threshold", "-v", value.to_s
		end
	end

	def failure_timeout
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:failure_timeout]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='failure-timeout']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def failure_timeout=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "failure-timeout"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "failure-timeout", "-v", value.to_s
		end
	end

	def multiple_active
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:multiple_active]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/primitive[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='multiple-active']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def multiple_active=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "multiple-active"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "multiple-active", "-v", value.to_s
		end
	end
end
