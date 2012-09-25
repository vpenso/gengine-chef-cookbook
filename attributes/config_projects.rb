# list of projects to be configured
default[:gengine][:projects] = Hash.new
# default Grid Engine Configuration for projects
default[:gengine][:defaults][:projects] = <<-EOF
oticket      0
fshare       0
acl          NONE
xacl         NONE
EOF
