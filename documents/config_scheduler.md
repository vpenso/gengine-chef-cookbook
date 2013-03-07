↪ `recipes/config_scheduler.rb`  
↪ `attributes/config_scheduler.rb`. 

Verify the configuration on a deployed master node with `qconf -ssconf`. Read the manual `sched_conf` for more details. 

## Basics 

In case of resource scarcity due to concurrent user requests the scheduler can enforce resource allocation policies. **Dynamic resource management aims for a predictable distribution of resources to users by pre-defined rules**. The scheduler operates as a thread within the _GridEngine Queue master_ and reorders periodically the list of jobs to dispatch on the existing resources. It moves the highest priority jobs to the beginning of the list, according to it configuration. 

In Grid Engine a scheduler run is trigger by one of the following three events

1. The `schedule_interval` **configures the time interval of the scheduler to periodically check the list of jobs **. On large clusters the interval should be bigger then 2 minutes, in order to prevent overloading of the queue master since the time frame is to small to reorder.
2. **Job submission and finishing jobs trigger a scheduler run after a defined delay**. The `flush_submit_sec` and `flush_finish_sec` parameters for huge clusters with many jobs should be longer the 10 seconds. Because immediate scheduling is set by these two parameters the scheduling interval only governs the freshness of the scheduling information.
3. **Administrators can enforce a scheduling run anytime** using the command `qconf -tsm`. This will report all  decisions to a file `schedd_runlog` for later inspection, also. 

Besides the scheduler configuration mentioned in the previous paragraph the following list highlights other **parameters relevant to big clusters**:

* The `schedd_job_info` configuration should be set false with more the 256 nodes, since it prevents a significant communication overhead between scheduler and queue master.
* The configuration `report_pjob_tickets` should be set to false in order to prevent the scheduler from sending priority information to the queue master (which is used for the output of `qconf -ext|-pri`).

## Configuration

Similar to the global configuration the scheduler configuration can be applied by attributes:

    "gengine" => {
      ...SNIP...
      "scheduler" => {
        "compensation_factor" => "2.000000",
        ...SNIP...
      }
      ...SNIP...
    }

Or by using a configuration file called `scheduler` in the repository:

    #scheduler:
    ...SNIP...
    halftime                          5400
    usage_weight_list                 cpu=1.000000,mem=0.000000,io=0.000000
    ...SNIP...

