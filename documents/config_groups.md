
# Groups and Departments

↪ `recipes/config_groups.rb`  
↪ `attributes/config_groups.rb`. 

# Basics

**User access lists (groups) and departments are used to limit resources (with quotas) and define resource shares for sets of users.** In order to define a department instead of an access list set `type DEPT`. (Note that user can only belong to a single department.) Details are described in the `access_list` manual. The user `entires` list is a comma separated list of user account names and/or group names prefixed by an `@` character. 

    » qconf -au devops design
    added "devops" to access list "design"
    [...SNIP...]
    » qconf -sul
    arusers
    deadlineusers
    defaultdepartment
    design
    » qconf -su design
    name    design
    type    ACL
    fshare  0
    oticket 0
    entries devops,@design

The `@group` notation is interesting to map user groups from the operating system into Grid Engine, without the necessity to add all individual user accounts beforehand.

## Configuration

Define groups of users with the attribute `node.gengine.groups`. Like for all other configurations you can define any parameter described in the **manual "access_list"**, e.g.:

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

