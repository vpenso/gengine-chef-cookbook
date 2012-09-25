# list of user groups (aka user access lists) to configure
default[:gengine][:groups] = Hash.new
# default Grid Engine attributes for user groups
default[:gengine][:defaults][:groups] = <<-EOF
type      ACL
fshare    0
oticket   0
entries   NONE
EOF
# by default an access list is defined not a department
