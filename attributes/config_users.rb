# list of users to be configured
default[:gengine][:users] = Hash.new
# default Grid Engine configuration for users
default[:gengine][:defaults][:user] = <<-EOF
  oticket         0
  fshare          0
  delete_time     0
  default_project NONE
EOF
