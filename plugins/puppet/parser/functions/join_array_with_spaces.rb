module Puppet::Parser::Functions
    newfunction(:join_array_with_spaces, :type => :rvalue) do |args|
        args[0].join(" ")
    end
end
