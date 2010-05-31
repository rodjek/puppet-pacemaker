require 'rexml/document'

Puppet::Type.type(:ha_crm_clone).provide(:crm) do
	desc "CRM shell support"

	commands :crm => "crm"
	commands :crm_resource => "crm_resource"

	def create
		crm "-F", "configure", "ms", resource[:id], resource[:resource]
	end

	def destroy
		crm "-F", "configure", "delete", resource[:id]
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:ensure] == :present ? true : false
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			primitive = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']")
			!primitive.nil?
		end
	end

	def priority
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:priority]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='priority']")
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
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='target-role']")
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
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='is-managed']")
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

	def clone_max
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:clone_max]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='resource-stickiness']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def clone_max=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "clone-max"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "clone-max", "-v", value.to_s
		end
	end

	def clone_node_max
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.vaule(:fqdn)
			resource[:clone_node_max]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='clone-node-max']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def clone_node_max=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "clone-node-max"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "clone-node-max", "-v", value.to_s
		end
	end

	def notify_clones
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:notify_clones]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='notify']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def notify_clones=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "notify"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "notify", "-v", value.to_s
		end
	end

	def globally_unique
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
			resource[:globally_unique]
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='globally-unique']")
			if nvpair.nil?
				:absent
			else
				nvpair.attribute(:value).value
			end
		end
	end

	def globally_unique=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "globally-unique"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "globally-unique", "-v", value.to_s
		end
	end

  def ordered
    if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      resource[:ordered]
    else
      cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
      nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='ordered']")
      if nvpair.nil?
        :absent
      else
        nvpair.attribute(:value).value
      end
    end
  end

  def ordered=(value)
    if value == :absent
      crm_resource "-m", "-r", resource[:id], "-d", "ordered"
    else
      crm_resource "-m", "-r", resource[:id], "-p", "ordered", "-v", value.to_s
    end
  end

  def interleave
    if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      resource[:interleave]
    else
      cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
      nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/master[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='interleave']")
      if nvpair.nil?
        :absent
      else
        nvpair.attribute(:value).value
      end
    end
  end

  def interleave=(value)
    if value == :absent
      crm_resource "-m", "-r", resource[:id], "-d", "interleave"
    else
      crm_resource "-m", "-r", resource[:id], "-p", "interleave", "-v", value.to_s
    end
  end
end
