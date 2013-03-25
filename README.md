# Description

**The "gengine" [Chef](http://wiki.opscode.com/) cookbook installs and configures the Grid Engine local resource management system.** You can find the latest version on GitHub:

<https://github.com/vpenso/gengine-chef-cookbook>

Requirements:

* At least Chef version 0.10.12.
* The only supported platform is Debian.
* No dependencies to other Chef cookbooks.
* General understanding of the Grid Engine cluster configuration.

"[Manual Configuration of GridEngine](documents/config_manual.md)" describes to general methodology of maintaining a GridEngine cluster configuration. Besides that refer to [Manual Installation](documents/install_manual.md) on Debian for a very basics example how to deploy a GridEngine test environment. 

# Recipes and Attributes

The Gengine cookbook distinguishes **three types of nodes: master, exec, and client**. The attribute `node.gengine.role` is set to _exec_ by default, which will render all nodes with the `recipe[gengine]` applied to its run-list to become execution nodes. It is assumed that each Grid Engine cluster has a single instance of a queue master node, and a significantly smaller number of [client nodes](documents/config_clients.md) compared to execution nodes. All exec and client nodes need to define the attributes `node.gengine.master` in order to communicate with the corresponding queue master. (Refer to the section Usage for a simple example.)

Depending on the assigned `node.gengine.role` for each particular node one of the recipes fo installation will be executed:

↪ `recipes/default.rb`  
↪ `recipes/install_master.rb`  
↪ `recipes/install_exec.rb`  
↪ `recipes/install_client.rb`

General Documentation:

- [Global](documents/config_global.md) cluster configuration.
- Adjustment of the [scheduler](documents/config_scheduler.md).
- Dynamic Resource Management with [Fair-Share](documents/config_sharetree.md).
- Creating [Groups and Departments](documents/config_groups.md), 
[Projects](documents/config_projects), and [Users](documents/config_users.md).
- Define resource pool with [Queues](documents/config_queues.md).
- [Parallel Environments](documents/config_parallel_environments.md) for
SMP and MPI.

## Resources

Resources **are requested by users on job submission, and are consumed by jobs**. They are defined by attributes (complex values) describing the resources capability. Typical consumable resources are memory or disk space. They can be defined on a global level and for each execution node (refer to the Execution Nodes section).

- Define resource capabilities with [Complex Values](documents/config_complex_values.md).
- Use [Quotas](documents/config_quotas.md) to limit resources for user, groups, and other thing.

## Execution Nodes

**Execution nodes are the machines hosting queues to accept jobs for local execution**. The majority of machines in a cluster are execution nodes (or number crunchers, batch nodes, worker nodes, whatever) in contrast to the queue master and a small number of job submit hosts for users.

- Define collections of execution nodes with [Host Groups](documents/config_host_groups.md).
- Define [Host Resources](documents/config_host_resources.md) (consumable by jobs.

# Usage

## Simple Example

The minimalistic installation of Grid Engine consists of two nodes, a queue master and a single execution node. The role for a Grid Engine queue master node with default configuration looks like:

    name "gengine_master"
    description "Grid Engine Queue Master Node"
    run_list( 
      "recipe[gengine]" 
    )
    default_attributes( 
      "gengine" => { 
        "role" => "master",
        "host_groups" => {
          "default" => {
            "nodes" => [ "lxb001.devops.test" ]
          }
        },
        "queues" => {
          "default" => {
            "hostlist" => "@default"
          }
        }
      } 
    )

You can read more about the attributes in the section above. For the beginning a "default" host group is defined including a single execution node called `lxb001.devops.test` (FQDN). Furthermore a queue "default" is specified to be hosted by nodes part of the host group "@default". __At least two runs of Chef are required to configure the queue master a the first time.__ The queue master node includes a Grid Engine client by default. Verify the successful configuration with:

    root@lxrm01:~$ qstat -g c
    CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE  
    --------------------------------------------------------------------------------
    default                           -NA-      0      0      0      1      0      1 
    root@lxrm01:~$ qhost
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxb001.devops.test      -               -     -       -       -       -       -

At this stage the master has not communicated with the execution node yet. The role for a Grid Engine execution node needs to define the FQDN of the queue master node, in the following example `lxrm01.devops.test`:

    name "gengine_exec"
    description "Grid Engine Execution Node"
    run_list( 
      "recipe[gengine]" 
    )
    default_attributes( 
      "gengine" => { 
         "master" => "lxrm01.devops.test" 
      } 
    )

Once the configuration was run successfully the queue master will see the resource metrics of the execution node.

    root@lxrm01:~$ qstat -g c
    CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE  
    --------------------------------------------------------------------------------
    default                           0.05      0      0      1      1      0      0 
    root@lxrm01:~$ qhost 
    HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
    -------------------------------------------------------------------------------
    global                  -               -     -       -       -       -       -
    lxb001.devops.test      lx26-amd64      1  0.05  497.0M   21.6M     0.0     0.0

For a quick test you can schedule an interactive login to the only execution node.

    root@lxrm01:~# qlogin
    local configuration lxrm01.devops.test not defined - using global configuration
    Your job 1 ("QLOGIN") has been submitted
    waiting for interactive job to be scheduled ...
    Your interactive job 1 has been successfully scheduled.
    Establishing builtin session to host lxb001.devops.test ...
    root@lxb001:~# uname -a
    Linux lxb001 3.2.0-3-amd64 #1 SMP Thu Jun 28 09:07:26 UTC 2012 x86_64 GNU/Linux
    root@lxb001:~# exit
    logout

From here on you can ad more execution nodes, dedicated client nodes used to submit batch jobs, and dive a more complex configuration of the queue master itself.

## Complex Role Example

The "gengine" cookbook includes a `test/roles/` directory with a file `gengine_master.rb` describing a more complex configuration example for a Grid Engine queue master node. You can use this role as a starting point for developing your deployment. 


    name "gengine_master"
    description "Development deployment of a GridEngine queue master"
    run_list(
      "recipe[gengine]",
    )
    default_attributes(
      "gengine" => {
        "role" => "master",
        "global" => {
          "execd_params"=> "H_MEMORYLOCKED=infinity",
          "auto_user_delete_time" => 0,
          "delegated_file_staging" => true
        },
        "scheduler" => {
          "compensation_factor" => "2.000000"
        },
        "complex_values" => {
          "tmpmounted" => "tmpmounted INT >= YES NO 0 0"
        },
        "groups" => {
          "design" => {
            "fshare" => 100000,
            "entries" => "joe,john,betty"
          },
          "devel" => {
            "type" => "DEPT",
            "entries" => "joe,john,stan"
          },
          "qa" => {
            "entries" => "tex,zed"
          }
        },
        "projects" => {
          "rendering" => { 
            "acl" => "design" 
          },
          "encoding" => {
            "oticket" => 50000,
            "acl" => "devel qa"
          }
        },
        "users" => {
          "betty" => { "default_project" => "rendering" },
          "zed" => { "oticket" => 5000 },
          "tex" => {}
        },
        "parallel_environments" => {
          "smp" => {
            "slots" => 4 
          }
        },
        "quotas" => {
          "max_slots_users" => {
            "description" => "max. default slots for users",
            "limits" => [ 
              "users {tex,zed} to slots=16",
              "users {*,!betty,!john} to slots=4" 
            ]
          }
        },
        "host_groups" => {
          "default" => {
            "nodes" => [
              "lxb001.devops.test",
              "lxb002.devops.test"
            ],
            "resources" => {
              "complex_values" => "slots=4"
            }
          },
          "highmem" => {
            "nodes" => [
              "lxb003.devops.test",
              "lxb004.devops.test"
            ]
          }
        },
        "queues" => {
          "default" => {
            "hostlist" => "@default @highmem"
          },
          "highmem" => {
            "hostlist" => "@highmem",
            "pe_list" => "smp"
          }
        },
        "clients" => {
          "nodes" => [
            "lxdev01.devops.test",
            "lxdev02.devops.test"
          ]
        }
      }
    )

## Configuration Repositories Example

Depending on the complexity of your configuration and the scale of the cluster you should decouple the Grid Engine configuration from your Grid Engine master role. Basically you only define the search queries for the Chef inventory to be used to assemble the list of execution nodes and client nodes. The actual queue master configuration is then loaded from another Git repository.

    name "gengine_master"
    description "Development deployment of a GridEngine queue master"
    run_list(
      "recipe[gengine]",
    )
    default_attributes(
      "gengine" => {
        "role" => "master",
        "repo" => { 
          "url" => "git://gitorious.devops.test/gengine/development.git" 
        },
        "host_groups" => { 
          "default" => { "search" => "role:gengine_exec" } 
         },
        "clients" => { "search" => "role:gengine_clients" }
      }
    )

You can then version you configuration independently and even implement a role back to previous tagged versions. Furthermore it is possible for administrators without Chef privileges to alter the configuration of a Grid Engine queue master instance.

# License

Copyright 2011-2013 Victor Penso

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[search]: http://wiki.opscode.com/display/chef/Search
[ogs]: http://gridscheduler.sourceforge.net/
[soge]: https://arc.liv.ac.uk/trac/SGE
[howto]: http://arc.liv.ac.uk/SGE/howto/
[list]: http://gridengine.org/mailman/listinfo/users
[debian]: http://packages.debian.org/search?searchon=sourcenames&keywords=gridengine
[debian_dev]: http://lists.alioth.debian.org/cgi-bin/mailman/listinfo/pkg-gridengine-devel
