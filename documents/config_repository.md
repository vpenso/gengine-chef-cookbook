
## Configuration Repository

↪ `recipes/config_repository.rb`

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

