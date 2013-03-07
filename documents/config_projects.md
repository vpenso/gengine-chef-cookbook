
# Projects

↪ `recipes/config_projects.rb`  
↪ `attributes/config_projects`

## Basics

**Projects are used to organize joint computational tasks of multiple users/groups**. Projects relate to at least one user group (access list `acl`). Details of the configuration are described in the `project` manual.

    » qconf -aprj
    root@lxdev01.devops.test added "rendering" to project list
    [...SNIP...]
    » qconf -sprjl
    rendering
    encoding
    » qconf -sprj rendering
    name rendering
    oticket 0
    fshare 100000
    acl design
    xacl NONE
    » qconf -dprj encoding
    root@lxdev01.devops.test removed "encoding" from project list

It is possible to configure overwrite tickets and functional tickets for projects, as well as to consider them in a fair-share configuration. Often projects are used to implement priorities for certain tasks.



## Configuration

Projects are used to **organize joint computational tasks from multiple users**. You can list all defined projects with `qconf -sprjl` to verify the configuration deployed by this recipe. Read the **manual "project"** for more details. 

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

