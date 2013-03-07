
# Host Groups

↪ `recipes/config_host_groups.rb`

## Basics

Host groups are used to combine groups of cluster nodes used to execute jobs under a single name. The manual `hostgroup` explains the configuration syntax in detail. Basically it is a name (prefixed by an `@` character) with an associated list of DNS host names (optionally FQDNs). **Defined host groups are used within a cluster queue configuration**. 

    » qconf -help | grep "host group"
    [-ahgrp group]                           add new host group entry
    [-Ahgrp file]                            add new host group entry from file
    [-dhgrp group]                           delete host group entry
    [-mhgrp group]                           modify host group entry
    [-Mhgrp file]                            modify host group entry from file
    [-shgrp group]                           show host group
    [-shgrp_tree group]                      show host group and used hostgroups as tree
    [-shgrp_resolved group]                  show host group with resolved hostlist
    [-shgrpl]                                show host group list
    » qconf -shgrpl
    @default
    @highmem
    » qconf -shgrp @default
    group_name @default
    hostlist lxdev01.devops.test lxdev02.devops.test
    » qconf -aattr hostgroup hostlist lxdev03.devops.test @default
    root@lxdev01.devops.test modified "@default" in host group list
    » qconf -shgrp @default
    group_name @default
    hostlist lxdev01.devops.test lxdev02.devops.test lxdev03.devops.test
    » qconf -dhgrp @highmem
    root@lxdev01.devops.test removed "@highmem" from host group entry list

Depending on the scale of the cluster(s) host groups can be relative dynamic. Most administrators will write scripts to configure huge list of nodes into host groups. Especially this part of the Grid Engine configuration can be automated with a configuration management system easily.

Host groups can be used to abstract different deviations of nodes, for example:

* Hardware resource limits `@8core`, `@highmem` or `@64GB`.
* Hardware architectures like `@i386`, `@amd64` or `@sparc64`.
* Platforms `@debian5`, `@centos6` or `redhat5`.

Generally it is recommended to keep a cluster as homogeneously as possible. Depending on strategy and scale **it  may be good to operate multiple clusters for different platforms/architectures to avoid binary incompatibilities for user applications**. Thus in big clusters with homogeneous platform and hardware a single host group `@default` is sufficient.

## Configuration

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

