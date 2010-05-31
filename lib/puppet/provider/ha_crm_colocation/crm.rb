require 'rexml/document'

Puppet::Type.type(:ha_crm_colocation).provide(:crm) do

	commands :crm => "crm"

	def create
    if resource[:resource_role]
      rsc = "#{resource[:resource]}:#{resource[:resource_role]}"
    else
      rsc = resource[:resource]
    end

    if resource[:with_resource_role]
      with_rsc = "#{resource[:with_resource]}:#{resource[:with_resource_role]}"
    else
      with_rsc = resource[:with_resource]
    end

		crm "-F", "configure", "colocation", resource[:id], "#{resource[:score]}:", rsc, with_rsc
	end

	def destroy
		crm "-F", "configure", "delete", resource[:id]
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      resource[:ensure] == :present ? true : false
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			colocation = REXML::XPath.first(cib, "//rsc_colocation[@id='#{resource[:id]}']")

      if resource[:resource_role]
        if colocation.attribute("rsc-role").value != resource[:resource_role]
          false
        end
      end

      if resource[:with_resource_role]
        if colocation.attribute("with-rsc-role").value != resource[:with_resource_role]
          false
        end
      end

			if colocation.attribute(:rsc).value != resource[:resource]
				false
      elsif colocation.attribute("with-rsc").value != resource[:with_resource]
        false
      elsif colocation.attribute(:score).value != resource[:score]
        false
      else
        true
			end
		end
	end
end
