
# Queues

↪ `recipes/config_queues.rb`  
↪ `attributes/config_queues.rb`

## Basics

In contrast to other resource management systems queues in Grid Engine are local to nodes. Each node in the cluster supports one or more **queues enforceing limits for the local resources**. Besides of defining the number of available slots (CPU cores) a **queue controls the job execution context**, nice levels and support of parallel environments, among other things. **Cluster queues defined defaults** and allow administrators an overview about all node instances of a queue. The `qstat` command shows the utilization of all cluster queues:

    » qstat -g c
    CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE  
    --------------------------------------------------------------------------------
    default                           0.18    457      0   6119   6672      0     96 
    highmem                           0.18    348      0    804   2224      0   1072 
    long                              0.18      1      0   2015   2224      0    208 


The **cluster queue configuration is inherited by the nodes, and can by overwritten locally**. In order to see the state of all queues on a particular host use the following command:

    » qstat -f -q *@lxdev01.devops.test
    queuename                      qtype resv/used/tot. load_avg arch          states
    ---------------------------------------------------------------------------------
    default@lxdev01.devops.test    BP    0/3/24         2.96     lx26-amd64    
    ---------------------------------------------------------------------------------
    long@dev01.devops.test         BP    0/0/8          2.96     lx26-amd64    
    ---------------------------------------------------------------------------------
    highmem@lxdev01.devops.test    BP    0/0/8          2.96     lx26-amd64    


By default jobs are dispatched to the least busy node/queue capable of satisfying all job and resource requirements. **A queue is where the job runs, and not where it is waiting to be queued** (state `qw`). Queues can be in different states: 

* **a**larm load threshold reached
* **d**isabled by user or admin
* **s**uspended by user or admin
* **u**nknown (`sge_execd` or server down?)
* **A**larm suspend threshold reached
* **C**alendar suspended
* **D**isabled
* **E**rror (`sge_execd` can’t reach shepherd)
* **S**ubordinate

## Configuration

Use the Chef attribute `node.gengine.queues` to configure individual queues like: 

    "gengine" => {
       ...SNIP...
       "queues" => {
         "default" => {
           "hostlist" => "@default @highmem"    
         },
         "highmem" => {
           "hostlist" => "@highmem"
         }
      }
      ...SNIP...
    }

All Grid Engine attributes to configure queue are desribed in the **manual "queue_conf"**. Verify the queue configuration with the command `qconf -sql` and `qconf -sq QUEUE_NAME`. Use the configuration repository sub-directory `queues/`, e.g. to specify a queue "short" in a file called `queues/short`:

    qname                 short
    hostlist              @default
    ...SNIP...
    s_rt                  03:55:00
    h_rt                  04:00:00
    ...SNIP...

## Cluster Queues 

Use the `qconf` command to manage cluster queues. The queue configuration is explained in detail in the `queue_conf` manual. In the beginning two queue configuration parameters are of particualar interest. The **`hostlist` defines the host groups providing resources to the cluster queue**. And **`slots` defines the maximum number of tasks per host**.


    » qconf -help | grep queue
      [-aq [queue_name]]              add a new cluster queue
      [-Aq fname]                     add a queue from file
      [-cq destin_id_list             clean queue
      [-dq destin_id_list             delete queue
      [-mq queue]                     modify a queue
      [-Mq fname]                     modify a queue from file
      [-sq [destin_id_list]]          show the given queue
      [-sql]                          show a list of all queues
    » qconf -sql
    default
    highmem
    long
    » qconf -sq long | grep "^[hs]_"
    s_rt                  500:00:00
    h_rt                  504:00:00
    s_cpu                 500:00:00
    h_cpu                 504:00:00
    s_fsize               INFINITY
    h_fsize               INFINITY
    s_data                INFINITY
    h_data                INFINITY
    s_stack               INFINITY
    h_stack               INFINITY
    s_core                INFINITY
    h_core                INFINITY
    s_rss                 2G
    h_rss                 2G
    s_vmem                2G
    h_vmem                2G

Queue limits are use to describe the resources provided for each job slot in the queue (find more details in the `setrlimit` manual). Above you can see the corresponding configuration for a queue called "long".  

### Host Queues

The most comprehensive output on queues `qstat -F` includes the **resource availability information for each queue on any host**.

    » qstat -F
    queuename                      qtype resv/used/tot. load_avg arch          states
    ---------------------------------------------------------------------------------
    default@lxb001.devops.test     BI    0/0/1          0.00     lx26-amd64    
            hl:load_avg=0.000000
            hl:load_short=0.000000
            hl:load_medium=0.000000
            hl:load_long=0.000000
            [...SNIP...]
            qc:slots=1
            qf:qname=default
            qf:hostname=lxb001.devops.test
            qf:tmpdir=/tmp
            qf:seq_no=0
            qf:rerun=0.000000
            [...SNIP...]

Each resource is prefixed with an indicator before the colon. The first letter defines the **scope: "g" global, "q" queue, "h" host**. The second character the source:

* "l" - a load value reported for the resource,
* "L" - a load value for the resource  after administrator defined load scaling has been applied,
* "c" - availability derived from the consumable  resources facility,
* "f" - a fixed availability definition derived from a non-consumable complex attribute or a fixed resource limit.

In order to overwrite cluster queue configurations for specific queues here the example of slots is showed. The execution node `lxb002.devops.test` has for CPU cores available but the queue `default` limits the node to a single slot.

    » qconf -sq default | grep slots
    slots                 1
    » qstat -F slots -q default@lxb002.devops.test
    queuename                      qtype resv/used/tot. load_avg arch          states
    ---------------------------------------------------------------------------------
    default@lxb002.devops.test     BI    0/0/1          0.45     lx26-amd64    
            qc:slots=1
    » qhost -h lxb002.devops.test
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxb002.devops.test      lx26-amd64      4  0.01 1002.7M   66.7M     0.0     0.0

Add an exception for this node in the queue configuration.

    » qconf -aattr queue slots  '[lxb002.devops.test=4]' default
    root@lxrm01.devops.test modified "default" in cluster queue list
    » qconf -sq default | grep slots
    slots                 1,[lxb002.devops.test=4]
    » qstat -f -q default@lxb002.devops.test
    queuename                      qtype resv/used/tot. load_avg arch          states
    ---------------------------------------------------------------------------------
    default@lxb002.devops.test     BI    0/0/4          0.01     lx26-amd64

### Thresholds

Each queue has two configuration options `load_thesholds` and `suspend_thresholds` used to protect the system. These configurations hold lists of resource=value pairs like `np_load_avg=1.75` defining the threshold limits. If one of these value is true the queue master reacts with:

* Queue reaches load threshold:
  * Stop accepting new jobs
  * Set queue into alarm state "a"
* Queue reaches suspend threshold:
  * Suspend nsupend jobs
  * Every `suspend_interval`, suspend nsuspend jobs
  * Set queue into alarm state "A"
* Queue leaves suspend threshold:
  * Resume nsuspend jobs at each suspend interval.

To display a list of resources (including complex values) usable in a tresholds definition run `qconf -sc`. 

### Queue Sorting

When multiple queues full-fill the requirements of a job a queue gets selected according to an (optional) sequence number `seq_no`.  

    » for queue in $(qconf -sql) ; do qconf -sq $queue | egrep "qname|seq_no" ; done 
    qname                 default
    seq_no                20
    qname                 highmem
    seq_no                70
    qname                 long
    seq_no                60

The example above configures a specific queue selection order prefer the `default` queue.

 

