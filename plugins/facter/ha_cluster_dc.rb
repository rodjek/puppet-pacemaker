require 'open3'

Facter.add("ha_cluster_dc") do
    setcode do
        stdin, stdout, stderr = Open3.popen3("/usr/sbin/crmadmin -D")
        stdout.read().split(' ')[-1].to_s.chomp
    end
end
