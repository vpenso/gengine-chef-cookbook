# list of parallel environments to configure
default[:gengine][:parallel_environments] = Hash.new
# defaults Grid Engine attributes for a parallel environment
default[:gengine][:defaults][:parallel_environment] = <<-EOF
slots              100
user_lists         NONE
xuser_lists        NONE
start_proc_args    /bin/true
stop_proc_args     /bin/true
allocation_rule    $pe_slots
control_slaves     TRUE
job_is_first_task  TRUE
urgency_slots      min
accounting_summary TRUE
EOF
