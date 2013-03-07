
# Quotas

↪ `recipes/config_quotas.rb`. 

## Basics

Resource quotas can limit users, groups, queues, parallel environments and hosts, among other things. They are defined as sets. The Grid Engine scheduler considers all configured resource quota sets. If multiple sets limit the same resource the most restrictive is applied. Like a firewall Grid Engine evaluates all rules within a sets sequentially and applies the first match. Following you can see a simple example limiting the number of job-slots for a queue:

    {
      name         slots_long_queue
      description  "max amount of slots for the long queue"
      enabled      TRUE
      limit        queues {long} to slots=400
    }
    {
      name         max_slots_default_users
      description  "max. slots for default users"
      enabled      TRUE
      limit        users {tex,betty,bob} to slots=2000
      limit        users {*,!zed} to slots=400
    }

The second rule set from the example above limits the total number of slots available to users. `users *` means “apply limit globally across all users” and `users {*}` means “apply limit individually to each user”. (Read the `sge_resource_quota` manual.)

    » qconf -help | grep quota
      [-arqs [rqs_list]]                 add resource quota set(s)
      [-Arqs fname]                      add resource quota set(s) from file
      [-drqs rqs_list]                   delete resource quota set(s)
      [-mrqs [rqs_list]]                 modify resource quota set(s)
      [-Mrqs fname [rqs_list]]           modify resource quota set(s) from file
      [-srqs [rqs_list]]                 show resource quota set(s)
      [-srqsl]                           show resource quota set list

## Configuration

Use the Chef attribute `node.gengine.quotas` to define resource quotas like:

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

