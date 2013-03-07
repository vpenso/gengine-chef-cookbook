
# Users

↪ `recipes/config_users.rb`  
↪ `attributes/config_users.rb`

## Basics

The **operating system user account name needs to be identical on all hosts part of a cluster**. Users without an additional account within the Grid Engine configuration can submit jobs to default resources. Grid Engine in the default configuration will create accounts temporarily.

    » qconf -sconf global | grep enforce_user 
    enforce_user                 auto
    » qconf -suserl
    devops
    » qconf -suser devops
    name devops
    oticket 0
    fshare 0
    delete_time 1354887987
    default_project NONE
    » qconf -muser devops
    root@lxdev01.devops.test modified "devops" in user list
    » qconf -suser devops
    name devops
    oticket 0
    fshare 0
    delete_time 0
    default_project rendering

The lifetime of temporary accounts is adjustable with `auto_user_delete_time` in the global configuration. Note that it is possible to make temporary accounts permanent by setting `delete_time` to zero.  **Whenever a user needs to get specific limits or ticket shares a Grid Engine system account needs to exist** (find details in the manual `user`).


## Configuration

**Users with valid operating system user accounts can submit jobs to the Grid Engine cluster**. A Grid Engine user account is automatically created since this cookbooks sets the global configuration `enforce_user   auto`. However in case the master needs to know about user accounts unknown to the hosting operating system or you do not want to get users automatically managed use the Chef attribute `node.gengine.users` like:

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

