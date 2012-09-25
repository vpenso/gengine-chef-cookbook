default[:gengine][:files][:exec_spool_dir] = '/var/spool/gridengine/execd'
# store the optional global default configuration
default[:gengine][:global] = Hash.new
# default global Grid Engine configuration
default[:gengine][:defaults][:global] = <<-EOF
#global:
execd_spool_dir              #{node.gengine.files.exec_spool_dir}
mailer                       /usr/bin/mail
xterm                        /usr/bin/xterm
prolog                       none
epilog                       none
shell_start_mode             posix_compliant
login_shells                 bash,sh,ksh,csh,tcsh
min_uid                      0
min_gid                      0
user_lists                   none
xuser_lists                  none
projects                     none
xprojects                    none
enforce_project              false
enforce_user                 auto
load_report_time             00:00:40
max_unheard                  00:05:00
reschedule_unknown           00:00:00
loglevel                     log_warning
administrator_mail           root
set_token_cmd                none
pag_cmd                      none
token_extend_time            none
shepherd_cmd                 none
qmaster_params               none
execd_params                 none
reporting_params             accounting=true reporting=false flush_time=00:00:15 joblog=false sharelog=00:00:00
finished_jobs                100
gid_range                    65400-65500
max_aj_instances             2000
max_aj_tasks                 75000
max_u_jobs                   0
max_jobs                     0
auto_user_oticket            0
auto_user_fshare             0
auto_user_default_project    none
auto_user_delete_time        86400
delegated_file_staging       false
reprioritize                 0
rlogin_daemon                builtin
rlogin_command               builtin
qlogin_daemon                builtin
qlogin_command               builtin
rsh_daemon                   builtin
rsh_command                  builtin
jsv_url                      none
jsv_allowed_mod              ac,h,i,e,o,j,M,N,p,w
EOF
