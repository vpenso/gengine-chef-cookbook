# system account used
default[:gengine][:user]   = 'sgeadmin'
default[:gengine][:group]  = 'sgeadmin'
# path to active system configuration
default[:gengine][:config] = '/etc/gridengine'
# nodes are used for job execution by default  
default[:gengine][:role] = 'exec' # alt. client|master
# FQDN of the node running the queue master
default[:gengine][:master] = String.new
