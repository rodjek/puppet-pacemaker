require 'rexml/document'

Puppet::Type.type(:ha_crm_group).provide(:crm) do

  commands :crm => "crm"
	commands :crm_resource => "crm_resource"

  def create
    with_rsc = resource[:resources]

    crm "-F", "configure", "group", resource[:id], with_rsc
  end

  def destroy
    crm "-F", "configure", "delete", resource[:id]
  end
	
  def target_role
	  cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
	  nvpair = REXML::XPath.first(cib, "//cib/configuration/resources/group[@id='#{resource[:id]}']/meta_attributes/nvpair[@name='target-role']")
		if nvpair.nil?
			:absent
		else
			nvpair.attribute(:value).value
		end
	end
	
  def target_role=(value)
		if value == :absent
			crm_resource "-m", "-r", resource[:id], "-d", "target-role"
		else
			crm_resource "-m", "-r", resource[:id], "-p", "target-role", "-v", value.to_s.capitalize
		end
	end

  def exists?
    cib = REXML::Document.new File.open("/var/lib/heartbeat/crm/cib.xml")
    colocation = REXML::XPath.first(cib, "//group[@id='#{resource[:id]}']")

    if colocation
      true
    else
      false
    end
  end
end
