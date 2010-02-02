module Haauthkeys =

autoload xfm

let eol             = Util.eol
let comment         = Util.comment
let empty           = Util.empty
let ws              = Util.del_ws " "
let num             = /[0-9]+/
let method          = /(md5|sha1|crc)/
let key_str             = /[^ \t\n]+/

let auth_selection  = [ label "auth" . Util.del_str "auth" . ws . store num . eol ]

let auth_method     = [ key num . ws 
                        . [ label "method" . store method ]
                        . (ws . [ label "key" . store key_str ])?
                        . eol ]

let lns             = (comment|empty|auth_selection|auth_method) *

let filter          = incl "/etc/ha.d/authkeys"
                        . Util.stdexcl

let xfm             = transform lns filter
