
# Parallel Environments

Usually jobs allocate a single CPU core. If an application 
needs multiple cores in parallel, this requirement must be
defined when submitting a job. GridEngine supports such 
requirements with so called "parallel environments".

↪ `recipes/config_parallel_environments.rb`  
↪ `attributes/config_parallel_environments.rb`

## Configuration

Details about the configuration of parallel environments are 
available in the manual *sge_pe*. The most important 
configuration option is the `allocation_rule`. **This cookbook
will configure parallel environments according to attributes
defined in `node.gengine.parallel_environments`**. The following
two examples illustrate this.

For programs based shared memory access the parallel environment
could be called "smp". The allocation rule `$pe_slots` forces 
all cores required by a job to be located on a single execution-node.
Within a role the following attributes would be defined:

    "gengine" => {
      ...SNIP...
      "parallel_environments" => {
        "smp" => {
          "slots" => 500,
          "allocation_rule" => "$pe_slots"
        }
      }
      ...SNIP...
    } 

Alternatively it is possible to use a file within a configuration
repository to define a parallel environment. For example a file
called `parallel_environments/openmpi` defines a parallel environment
called "openmpi", and would contain content like:

    pe_name            openmpi
    slots              10000
    allocation_rule    $fill_up
    ...SNIP...

In order to verify the configuration deployed by Chef use the 
commands `qconf -spl` and `qconf -sp`, like:

    » qconf -sp openmpi
    pe_name            openmpi
    slots              6000
    user_lists         NONE
    xuser_lists        NONE
    start_proc_args    /bin/true
    stop_proc_args     /bin/true
    allocation_rule    $fill_up
    control_slaves     TRUE
    job_is_first_task  TRUE
    urgency_slots      min
    accounting_summary FALSE

## Usage

Considering the example configuration above the execution of a program
based on shared memory uses the "smp" parallel environment with the
submit option `-pe smp CORES`. This will ensure that the number of 
CORES you have defined will be allocated on a single execution node. 

Applications based on a distributed-memory architecture communicating 
using MPI are submitted to the "openmpi" parallel environment with the 
option `-pe openmpi CORES`. They will be distributed among as many execution 
nodes as GridEngine identifies as suitable. 

The following script illustrates the utilization of a parallel 
environment "openmpi". The variable `PATH_TO_SHARED_STORAGE` should be
replaced with storage available among all execution nodes.  For the 
propose of this example we call this script `mpi_submit.sge`:

    #!/bin/bash
    #$ -j y
    #$ -pe openmpi 50
    #$ -N mpi_test
    #$ -wd /tmp
    _target=PATH_TO_SHARED_STORAGE
    _exec=$1
    format='+%Y/%m/%d-%H:%M:%S'
    echo Hello from $USER@`hostname`:`pwd` 
    echo `date $format` Starting MPI...
    mpirun $_exec
    echo `date $format` ..finished. 
    cp -v $SGE_STDOUT_PATH $_target/$JOB_ID.log

Compile a MPI program and verify that it execute properly. Then submit it
to the cluster:

    » mpicc -o hello_world hello_world.c 
    » mpirun -np 4 hello_world.o 
    Hello world from process (pid 32213) rank 1 (of 4 processes)
    Hello world from process (pid 32212) rank 0 (of 4 processes)
    Hello world from process (pid 32214) rank 2 (of 4 processes)
    Hello world from process (pid 32215) rank 3 (of 4 processes)
    » cp hello_world $PATH_TO_SHARED_STORAGE/
    » qsub mpi_submit.sge $PATH_TO_SHARED_STORAGE/hello_world    

Monitor the state of your job with `qstat -g t` to show all processes. 


