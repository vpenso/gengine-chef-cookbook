
# Debian Specifics

Debian provides binaries for Grid Engine with the packages:

`gridengine-master`  
`gridengine-exec`  
`gridengine-client`

The queue master stores its **log in** `/var/spool/gridengine/qmaster/messages`. It does not only contain scheduling info but also error information about the daemon as well as about failed jobs. The corresponding daemon `sge_qmaster` needs to be running in order to accept jobs. You can check by looking for processes from the user `sgeadmin`. **Control the master daemons using the script** `/etc/init.d/gridengine-master`.

In order to accept jobs from the queue master each execution node needs to have a correctly configured `sge_execd` daemon running under the user account `sgeadmin`. **Control the execution daemons using the init script** `/etc/init.d/gridengine-exec`. **In case of communication problem between queue master and the exec node lookout for log files like** `/tmp/exed_messages.[pid]`. Also the queue master indicates authorization problems with execution nodes in its log-file. The job spool directory is located in `/var/spool/gridengine/execd/`.

## Manual Installation

The most simple setup configures a single machine to host the Grid Engine queue master, to act as an execution node and to be an job submit node with client command-line interface. The following example is build with a **virtual machine named `lxdev01.devops.test`** running Debian Wheezy as operating system.

    » apt-get install gridengine-master gridengine-exec gridengine-client
    [...SNIP...]
    » /etc/init.d/gridengine-exec start
    » qhost
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxdev01.devops.test     lx26-amd64      1  0.42  497.0M   64.7M     0.0     0.0

After installing all the packages the queue master daemon `sge_qmaster` should be running. Once the init-script `gridengine-exec` starts an instance of `sge_execd` daemon the host can execute jobs. Before a job can be submitted a **host group `@default`** is defined, which in turn is used to configure a **queue `default`**.

    » qconf -ahgrp @default
    root@lxdev01.devops.test added "@default" to host group list
    » qconf -shgrp @default
    group_name @default
    hostlist lxdev01.devops.test
    » qconf -aq default
    root@lxdev01.devops.test added "default" to cluster queue list
    » qconf -sq default | head -2
    qname                 default
    hostlist              @default

Last thing to do is to add the host to the list of submit nodes.

    » qstat -g c
    CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE  
    --------------------------------------------------------------------------------
    default                           0.02      0      0      1      1      0      0
    » qstat -f
    queuename                      qtype resv/used/tot. load_avg arch          states
    ---------------------------------------------------------------------------------
    default@lxdev01.devops.test    BIP   0/0/1          0.01     lx26-amd64
    » qconf -as $(hostname -f)
    lxdev01.devops.test added to submit host list

Installation and configuration is done with root privileges, to submit the first job a user account `devops` is used.

    » cat echo.sge
    echo $USER@`hostname`:`pwd`
    » qsub -j y -o /tmp/job.log -wd /tmp echo.sge
    Your job 1 ("echo.sge") has been submitted
    » qstat
    job-ID  prior   name       user         state submit/start at     queue    slots
    --------------------------------------------------------------------------------
          1 0.00000 echo.sge   devops       qw    12/06/2012 13:48:25          1
    » cat /tmp/job.log 
    devops@lxdev01:/tmp
    » qacct -j 1
    ==============================================================
    qname        default             
    hostname     lxdev01.devops.test 
    group        devops              
    owner        devops              
    project      NONE                
    department   defaultdepartment   
    jobname      echo.sge      
    [...SNIP...]

The actually build a "cluster" of machines at least a **second execution node `lxdev02.devops.test`** is needed. Before this node is installed we can add it to the `@default` host group.

    » qconf -mhgrp @default
    lxdev01.devops.test modified "@default" in host group list
    » qconf -shgrp @default
    group_name @default
    hostlist lxdev01.devops.test lxdev02.devops.test
    » qhost
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxdev01.devops.test     lx26-amd64      1  0.01  497.0M   65.5M     0.0     0.0
    lxdev02.devops.test     -               -     -       -       -       -       -

On the node itself install only the execution node package and **configure the address of the queue master** in the file `/var/lib/gridengine/default/common/act_qmaster`.

    » apt-get install gridengine-exec
    [...SNIP...]
    » echo "lxdev01.devops.test" > /var/lib/gridengine/default/common/act_qmaster
    » service gridengine-exec restart
    Restarting Sun Grid Engine Execution Daemon: sge_execd.

After restarting the execution daemon, it should **register with the queue master**.

    » qhost
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxdev01.devops.test     lx26-amd64      1  0.01  497.0M   65.7M     0.0     0.0
    lxdev02.devops.test     lx26-amd64      1  0.14 1003.0M   64.5M     0.0     0.0
    » for i in {1..10}; do qsub -b y sleep -- 10 ; done
    Your job 7 ("sleep") has been submitted
    Your job 8 ("sleep") has been submitted
    Your job 9 ("sleep") has been submitted
    Your job 10 ("sleep") has been submitted
    Your job 11 ("sleep") has been submitted
    Your job 12 ("sleep") has been submitted
    Your job 13 ("sleep") has been submitted
    Your job 14 ("sleep") has been submitted
    Your job 15 ("sleep") has been submitted
    Your job 16 ("sleep") has been submitted

**Jobs will be distribute equally** to both execution nodes.

    » qstat
    job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
    -----------------------------------------------------------------------------------------------------------------
          7 0.50000 sleep      devops       r     12/06/2012 14:45:54 default@lxdev02.devops.test        1        
          8 0.50000 sleep      devops       r     12/06/2012 14:45:54 default@lxdev01.devops.test        1        
          9 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         10 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         11 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         12 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         13 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         14 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         15 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1        
         16 0.50000 sleep      devops       qw    12/06/2012 14:45:47                                    1   
    » qacct -o devops -j | egrep "jobnumber|exit"
    [...SNIP...]
    jobnumber    11                  
    exit_status  0                   
    jobnumber    13                  
    exit_status  0                   
    jobnumber    14                  
    exit_status  0                   
    jobnumber    15                  
    exit_status  0                   
    jobnumber    16                  
    exit_status  0   


