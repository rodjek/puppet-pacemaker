module Hacf =
  autoload xfm

  let entry = Spacevars.entry
  let generic_entry_key = Spacevars.entry_re - /mcast/
  let ws = Util.del_ws_spc
  let eol = Util.eol
  let comment = Util.comment
  let empty = Util.empty

  let generic_entry = entry generic_entry_key
  let mcast_entry = [ label "mcast" . Util.del_str "mcast" . ws 
                        . [ label "interface" . store /[a-zA-Z0-9\.]+/ ] . ws
                        . [ label "group" . store /[0-9\.]+/ ] . ws
                        . [ label "port" . store /[0-9]+/ ] . ws
                        . [ label "ttl" . store /[0-9]+/ ] . ws
                        . Util.del_str "0" . eol 
                    ]

  let lns = (comment|empty|mcast_entry|generic_entry)*

  let filter      = Util.stdexcl
                    . incl "/etc/ha.d/ha.cf"

  let xfm         = transform lns filter

