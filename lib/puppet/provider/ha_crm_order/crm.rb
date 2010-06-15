require 'rexml/document'

Puppet::Type.type(:ha_crm_colocation).provide(:crm) do

	commands :crm => "crm"

	def create
    if resource[:first_action]
      first_rsc = "#{resource[:first]}:#{resource[:first_action]}"
    else
      first_rsc = resource[:first]
    end

    if resource[:then_action]
      then_rsc = "#{resource[:then]}:#{resource[:then_action]}"
    else
      then_rsc = resource[:then]
    end

		crm "-F", "configure", "order", resource[:id], "#{resource[:score]}:", first_rsc, then_rsc, "symmetrical=#{resource[:symmetrical].to_s}"
	end

	def destroy
		crm "-F", "configure", "delete", resource[:id]
	end

	def exists?
		if resource[:only_run_on_dc] and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      resource[:ensure] == :present ? true : false
		else
			cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
			colocation = REXML::XPath.first(cib, "//rsc_order[@id='#{resource[:id]}']")

      if resource[:first_action]
        if colocation.attribute("first-action").value != resource[:first_action]
          false
        end
      end

      if resource[:then_action]
        if colocation.attribute("then-action").value != resource[:then_action]
          false
        end
      end

			if colocation.attribute(:first).value != resource[:first]
				false
      elsif colocation.attribute(:then).value != resource[:then]
        false
      elsif colocation.attribute(:score).value != resource[:score]
        false
      else
        true
			end
		end
	end
end
