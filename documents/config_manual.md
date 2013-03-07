# Manual Configuration of GridEngine

Unless a dedicated management system is configuring Grid Engine, administrators have basically three ways to maintain the system. First a graphical user-interface called Qmon. Second using the command-line tool `qconf` for interactive editing of the configuration. Last by using `qconf` to read the configuration from text files. **Since GridEngine is complex and involves the configuration of users and projects, resources, quotas and a sharetree, just to name a few, it is recommended to keep your configuration at least as backup in text files.**

In order to work with text-files, the following procedure applies. Here exemplified by the scheduler configuration which is displayed with the command `qconf -ssconf` and described in the manual `sched_conf`.

    » qconf -help | grep scheduler
      [-msconf]                    modify scheduler configuration
      [-Msconf fname]              modify scheduler configuration from file
      [-sss]                       show scheduler state
      [-ssconf]                    show scheduler configuration
      [-tsm]                       trigger scheduler monitoring
    » qconf -ssconf > /tmp/gengine_scheduler.conf
    [...SNIP...]
    » qconf -Msconf /tmp/gengine_scheduler.conf

Typically the configuration is maintained within a file under version control and then loaded into the running system with the command `qconf -Msconf` in this example. **Generally configuration templates work like**:

* Add from a template file with `qconf -A<cmd> <file> <file> ...`
* Delete from a template file with `qconf -D<cmd> <file> <file> ...`
* Modify from a template file with `qconf -M<cmd> <file> <file> ...`

Deployment multiple cluster and/or operation of huge clusters (>100 nodes) is relieved a lot by the utilization of a configuration management system, especially if the Grid Engine configuration isn't hosted on a cluster wide shared file-system. 

