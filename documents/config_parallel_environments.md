
# Parallel Environments

↪ `recipes/config_parallel_environments.rb`  
↪ `attributes/config_parallel_environments.rb`

## Basics

To do.

## Configuration

Use the Chef attribute `node.gengine.parallel_environments` to define parallel environments:

    "gengine" => {
      ...SNIP...
      "parallel_environments" => {
        "smp" => {
          "slots" => 4
        }
      }
      ...SNIP...
    } 

Use sub-directory `parallel_environments/` of the configuration repository to define a parallel environment. For example to add a parallel environment called "mpi" create a file called `parallel_environments/mpi` with content like:

    pe_name            mpi
    slots              16
    allocation_rule    $fill_up
    ...SNIP...

Verify the configuration of a parallel environment with the command `qconf -spl` and `qconf -sp PE_NAME`. Further details about the configuration of parallel environments are available in the **manual "sge_pe"**.
