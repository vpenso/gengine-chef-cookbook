# Description

The "gengine" cookbook installs and configures the Grid Engine local resource management system (known as Sun Grid Engine before).

Requirements:

* At least Chef version 0.10.12.
* The only supported platform is Debian.
* No dependencies to other Chef cookbooks.
* General understanding of the Grid Engine cluster configuration.

References:

* [Open Grid Scheduler][ogs] on Sourceforge.
* [Son of Grid Engine][soge] from the University of Liverpool.
* Debian [package][debian] information, and maintainers [site][debian_dev].
* [Mailing list][list] and [HowTos][howto].

# Recipes and Attributes

Find the code in `recipes/default.rb`

The Gengine cookbook distinguishes **three types of nodes: master, exec, and client**. The attribute `node.gengine.role` is set to _exec_ by default, which will render all nodes with the `recipe[gengine]` applied to its run-list to become execution nodes. It is assumed that each Grid Engine cluster has a single instance of a queue master node, and a significantly smaller number of client nodes compared to execution nodes. All exec and client nodes need to define the attributes `node.gengine.master` in order to communicate with the corresponding queue master. (Refer to the section Usage for a simple example.)

Depending on the assigned `node.gengine.role` for each particular node one of the recipes fo installation will be executed:  `recipes/install_master.rb`,  `recipes/install_exec.rb`, `recipes/install_client.rb`.

## Repository

Find the code in `recipes/config_repository.rb`

The complex part of a Grid Engine cluster configuration applies only to the master. With the help of this cookbook any aspect of the queue master configuration can be defined by attributes. Since such a queue master configuration becomes very complex for large deployments, and is surprisingly dynamic depending on the number of users/groups and applications, **the configuration can be maintained in an configuration repository**. This repository backed by the version control system Git is independent of Chef roles and the Gengine cookbook.  

All **configurations from the configuration repository will be merged with configurations defined by Chef attributes in a master role**. The repository configuration can not overwrite Chef attributes, and is only merged where applicable. To synchronise with a remote configuration repository define the attribute `node.gengine.repo.url`, e.g.:

    "gengine" => {
      "repo" => {
        "url" => "git://gitorious.devops.test/gengine/production.git"
      }
    }

Freeze the configuration to a tagged version of the configuration repository using the attribute `node.gengine.repo.version`. The structure of the configuration repository is similar to the attributes used to configure Grid Engine. The following listing shows the basic directory and file structure:

    ├── complex_values
    ├── global
    ├── groups
    │   └── default
    ├── host_groups
    │   ├── default
    │   └── highmem
    ├── parallel_environments
    │   └── openmpi
    ├── projects
    │   └── default
    ├── queues
    │   ├── default
    │   └── short
    ├── quotas
    │   ├── max_slots_projects
    │   └── max_slots_users
    ├── README.md
    ├── scheduler
    ├── sharetree
    └── users
        ├── betty
        ├── joe
        └── john

## Global

Find the code in `recipes/config_global.rb` and the default Grid Engine global attributes in `attributes/config_global.rb`. The **manual "sge_conf"** contains a detailed description. Use the attribute `node.gengine.global` to overwrite the cookbook defaults. 


    "gengine" => {
      ...SNIP...
      "global" => {
        "execd_params"=> "H_MEMORYLOCKED=infinity",
        "auto_user_delete_time" => 0,
        "delegated_file_staging" => true
        ...SNIP...
      }
      ...SNIP...
    }

On a deployed Grid Engine master you can verify the configuration using the command `qconf -sconf`. The global configuration can be altered by a file called `global` in the configuration repository. Such a configuration looks like:

    #global:
    ...SNIP...
    login_shells                 zsh,bash,sh
    gid_range                    65400-66500
    ...SNIP...

## Scheduler 

Find the code in `recipes/config_scheduler.rb` and the Grid Engine default scheduler attributes in `attributes/config_scheduler.rb`. Similar to the global configuration the scheduler configuration can be applied by attributes:

    "gengine" => {
      ...SNIP...
      "scheduler" => {
        "compensation_factor" => "2.000000",
        ...SNIP...
      }
      ...SNIP...
    }

Or by using a configuration file called <tt>scheduler</tt> in the repository:

    #scheduler:
    ...SNIP...
    halftime                          5400
    usage_weight_list                 cpu=1.000000,mem=0.000000,io=0.000000
    ...SNIP...

Verify the configuration on a deployed master node with `qconf -ssconf`. Read the **manual "sched_conf"** for more details. 

## Fair-Share

Find the code in `recipes/config_sharetree.rb`.

Buy default the _gengine_ cookbook will deploy a fair-shair configuration to equally distribute all resources among user, groups and projects. In case you don't want the "sharetree" to be modified by the cookbook comment the including of the recipe in `recipes/install_master.rb`.

In order **to deploy a more complex configuration for fair-share use a file `sharetree` in the configuration repository**. This will overwrite the default from the cookbook. Inspect the sharetree on a deployed master with the command `qconf -sstree`. The syntax of the sharetree file is explained in the **manual "share_tree"**.

## Groups and Departments

Find the code in `recipes/config_groups.rb` and the default attributes for Grid Engine user groups (aka access lists) in `attributes/config_groups.rb`. Define groups of users with the attribute `node.gengine.groups`. Like for all other configurations you can define any parameter described in the **manual "access_list"**, e.g.:

    "gengine" => {
      ...SNIP...
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
          "oticket" => 5000,
          "entires" => "tex,zed"
        }
        ...SNIP...
      }
      ...SNIP...
    }

**User access lists (groups) are used to limit access permission to resouces.** Define user group definitions in the sub-directory `groups/` in a configuration repository. For example to create a group "support" use a file called `groups/support` with a definition like:

    name      support
    oticket   0
    fshare    20000
    entires   mark,andy,anna 

In order to define a department instead of an access list set `type   DEPT`. Note that **user can only belong to a single department**.

## Projects

Find the code in `recipes/config_projects.rb` and the Grid Engine default attributes for projects in `attributes/config_projects`. Projects are used to **organize joint computational tasks from multiple users**. You can list all defined projects with `qconf -sprjl` to verify the configuration deployed by this recipe. Read the **manual "project"** for more details. 

Use the attribute `node.gengine.projects` to add projects to the master configuration:


    "gengine" => {
      ...SNIP...
      "projects" => {
        "rendering" => { 
          ...SNIP...
          "fshare" => 100000,
          "acl" => "design"
        },
        "encoding" => {
          "oticket" => 50000,
          "acl" => "devel qa"
        }
        ...SNIP...
      }
      ...SNIP...
    }

Define projects in the configuration repository in a sub-directory `projects/` using the name of the project as file name. For example `projects/decoding`:

    name     decoding
    oticket  10000
    acl      support

## Users

Find the code in `recipes/config_users.rb` and the default Grid Engine configuration attributes for user accounts in `attributes/config_users.rb`. **Users with valid operating system user accounts can submit jobs to the Grid Engine cluster**. A Grid Engine user account is automatically created since this cookbooks sets the global configuration `enforce_user   auto`. However in case the master needs to know about user accounts unknown to the hosting operating system or you do not want to get users automatically managed use the Chef attribute `node.gengine.users` like:

    "gengine" => {
      ...SNIP...
      "users" => {
        "betty" => {
          "default_project" => "rendering"
        },
        "zed" => {
          "oticket" => 5000
        },
        "tex" => {},
        ...SNIP...
      }
      ...SNIP...
    } 

It is possible to define Grid Engine user accounts within the configuration repository inside a sub-directory called `users/`. The add a user "Tom" create a file called `users/tom` with optional content like:

    name            tom
    oticket         0
    fshare          0
    delete_time     0
    default_project NONE

Verify the user configuration on the master with `qconf -suserl`.


## Parallel Environments

Find the code in `recipes/config_parallel_environments.rb` and the Grid Engine default attributes for a parallel environment in `attributes/config_parallel_environments.rb`. Use the Chef attribute `node.gengine.parallel_environments` to define parallel environments:


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

##  Resources

Resources **are requested by users on job submission, and are consumed by jobs**. They are defined by attributes (complex values) describing the resources capability. Typical consumable resources are memory or disk space. They can be defined on a global level and for each execution node (refer to the Execution Nodes section).

### Complex Values

Find the code in `recipes/config_complex_values.rb` and the by default defined resources in `attributes/config_complex_values.rb`. Overwrite the default resources or define additional resources with the Chef attribute `node.gengine.complex_values`, e.g.:

    "gengine" => {
      ...SNIP...
      "complex_values" => {
        "tmpmounted" => "tmpmounted INT >= YES NO 0 0",
        ...SNIP...
      }
      ...SNIP...
    } 

Verify the configuration of Grid Engine complex values with the command `qconf -sc`. Read the **manual "complex"** for more details. Define a file `complex_values` in the configuration repository like:

    #name               shortcut      type        relop requestable consumable default  urgency 
    #------------------------------------------------------------------------------------------
    lustre              lustre        INT         >=    YES         NO         0        0
    ...SNIP...

### Quotas

Find the code in `recipes/config_quotas.rb`. Uee the Chef attribute `node.gengine.quotas` resource quotas like:

    "gengine" => {
      ...SNIP...
      "quotas" => {
        "max_slots_users" => {
          "description" => "max. default slots for users",
          "limits" => [ 
            "users {tex,zed} to slots=16",
            "users {*,!betty,!john} to slots=4" 
          ]
        },
        ...SNIP...
      },
      ...SNIP...
    }

The configuration repository sub-directory `quotas/` is used to add quota descriptions, e.g. a quota called "max_slots_projects" in a file called `quotas/max_slots_projects":

     description    "max. slots for projects"
     limit          projects {rendering} to slots=4
     limit          projects {encoding} to slots=16

Verify the Grid Engine quota configuration with the commands `qconf -srqsl` and `qconf -srqs QUOTA_NAME`. 

## Execution Nodes

Find the code in <tt>recipes/config\_host\_groups.rb</tt>.

### Host Groups

The definition of host groups in Grid Engine is described in the **"hostgroup" manual**. This cookbook will merge three sources to collect a list of nodes belonging to a host group. First you can define the attribute `node.gengine.host_groups` like:

    "gengine" => {
      ...SNIP...
      "host_groups" => {
        "default" => {
          "nodes" => [
            "lxb001.devops.test",
            "lxb002.devops.test"
          ]
        },
        "highmem" => {
          ...SNIP...
        }
      }
      ...SNIP...
    }

It contains a list of host group definitions where the key becomes the host group name in Grid Engine containing the list of "nodes". Second you can have a configuration file in the sub-directory `host_groups/` of your configuration repository. The name of the file needs to be the name of the host group, e.g. `host_groups/highmem`:

    group_name @highmem
    hostlist lxb003.devops.test lxb004.devops.test lxb005.devops.test

Note that if you include the `group_name` into the host group definition (which isn't required for this cookbook) the file will be still compatible with the `qconf -Mhgrp` command. The third and last method to define a host group is be searching the Chef inventory for machines, e.g.:


    "gengine" => {
      ...SNIP...
      "host_groups" => {
        "default" => {
          ...SNIP...
          "search" => "role:gengine_exec"
        }
      }
      ...SNIP...
    }

The query can be formulated according to the rules for Chef [search][search]. Verify the host group configuration with the command `qconf -shgrpl`.

### Host Resources

In addition to defining host lists for each host group it is possible to specify resource attributes (e.g. `complex_values` or `load_scaling`). Read the **manual "sge_complex"** for a detailed list of resources.

    "gengine" => {
      ...SNIP...
      "host_groups" => {
        "default" => {
          ...SNIP...
          "resources" => {
            "complex_values" => "slots=1",
            "load_scaling" => "NONE"
          }
        }
      }
      ...SNIP...
    }

## Queues

Find the code in `recipes/config_queues.rb` and the default Grid Engine attributes for queues in `attributes/config_queues.rb`. Use the Chef attribute `node.gengine.queues` to configure individual queues like: 

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

 

## Client Nodes

Find the code in `recipes/config_clients.rb`. Grid Engine clients have the user-space tools installed and are used to manage jobs on the cluster. Often they are referred to as submit nodes. Use the Chef attribute `node.gengine.clients.nodes` to define submit nodes:

    "gengine" => {
      ...SNIP...
      "clients" => {
        "nodes" => [
          "lxdev01.devops.test",
          "lxdev02.devops.test"
        ]
      }
      ...SNIP...
    }

Grid Engine client nodes are by default able to be used for administrative work too. You can alter this behavior by setting the Chef attribute `node.gengine.clients.admins` to false. Verify the configuration with the commands `qconf -ss` and `qconf -as`. By defining the Chef attribute `node.gengine.clients.search` the Chef inventory is used to collect a list of Grid Engine clients to configure, e.g.:

    "gengine" => {
      ...SNIP...
      "clients" => {
        ...SNIP...
        "search" => "role:gengine_client"
      }
      ...SNIP...
    }

Chef inventory [searchs][search] can't be used with Chef Solo.

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

Copyright 2011-2012 Victor Penso

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
