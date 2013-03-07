
# Host Resources

## Basics

Each **execution host can overwrite some of the cluster queue configurations, have specific complex values (requestable and consumable resources) and be exclusive for groups of users or project**. The host specific configuration is described in the `host_conf` manual. As with all components in Grid Engine there a different ways to configure attributes of hosts.

    » qconf -help | grep [aAdDmMprR]attr
    [-aattr obj_nm attr_nm val obj_id_list]  add to a list attribute of an object
    [-Aattr obj_nm fname obj_id_list]        add to a list attribute of an object
    [-dattr obj_nm attr_nm val obj_id_list]  delete from a list attribute of an object
    [-Dattr obj_nm fname obj_id_list]        delete from a list attribute of an object
    [-mattr obj_nm attr_nm val obj_id_list]  modify an attribute (or element in a sublist)
    [-Mattr obj_nm fname obj_id_list]        modify an attribute (or element in a sublist) 
    [-rattr obj_nm attr_nm val obj_id_list]  replace a list attribute of an object
    [-Rattr obj_nm fname obj_id_list]        replace a list attribute of an object
    » qconf -rattr exechost complex_values slots=8 lxdev01.devops.test
    [...SNIP...]
    » qconf -Mattr exechost /tmp/resource.conf lxdev02.devops.test
    [...SNIP...]
    » qconf -se node02
    hostname              lxdev02.devops.test
    load_scaling          NONE
    complex_values        slots=24
    load_values           arch=lx26-amd64,num_proc=24,mem_total=64560.765625M, \
                          swap_total=63993.253906M,virtual_total=128554.019531M, \
    [....SNIP...]
                          np_load_long=0.768750,tmp_free=163G
    processors            24
    user_lists            NONE
    [...SNIP...]
    » qconf -me lxdev02.devops.test
    root@lxdev01.devops.test modified "lxdev02.devops.test" in exechost list
    » qconf -se lxdev02.devops.test | grep complex_values
    complex_values        slots=1

Specially consumable `complex_values` can play very important role in a scheduling strategy, like the number of job slots (equaling the number of cores), GPUs or software licences. For non consumable resource (e.g. existance of shared file-system), simple re-lop comparison occurs between job requests. If "true" the job can be executed on a host.

## Configuration

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

