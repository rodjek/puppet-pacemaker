require 'rexml/document'

Puppet::Type.type(:ha_crm_order).provide(:crm) do

	commands :crm => "crm"

  def lensure
    return  resource[:ensure]
  end

  def id
    return resource[:id]
  end

  def first
    return resource[:first]
  end

  def first_action
    return resource[:first_action]
  end

  def lthen
    return resource[:then]
  end

  def then_action
    return resource[:then_action]
  end

  def score
    return resource[:score]
  end

  def symmetrical
    return resource[:symmetrical]
  end

  def only_run_on_dc
    return resource[:only_run_on_dc]
  end
	
  def create
    if first_action
      first_rsc = "#{first}:#{first_action}"
    else
      first_rsc = first
    end

    if then_action
      then_rsc = "#{lthen}:#{then_action}"
    else
      then_rsc = lthen
    end
    begin
		  crm "-F", "configure", "delete", id
		rescue
      # Already deleted
    end
    crm "-F", "configure", "order", id, "#{score}:", first_rsc, then_rsc, "symmetrical=#{symmetrical.to_s}"
	end

	def destroy
		crm "-F", "configure", "delete", id
	end

	def exists?
		if only_run_on_dc and Facter.value(:ha_cluster_dc) != Facter.value(:fqdn)
      lensure == :present ? true : false
		else
			cib = REXML::Document.new `/usr/sbin/crm configure save xml -`
			rsc_order = REXML::XPath.first(cib, "//rsc_order[@id='#{id}']") 
      
      return false if not rsc_order

      if first_action
        if rsc_order.attribute(:first-action).value != first_action
          return false
        end
      end

      if then_action
        if rsc_order.attribute(:then-action).value != then_action
          return false
        end
      end
      #We use crm directly now so need to convert inf to INFINITY for the match
      if score == :inf
        score = 'INFINITY'
			end
      if rsc_order.attribute(:first).value.downcase != first.downcase
				return false
      elsif rsc_order.attribute(:then).value.downcase != lthen.downcase
        return false
      elsif rsc_order.attribute(:score).value.downcase != score.downcase
        return false
      else
        return true
			end
      return true
		end
	end
end
