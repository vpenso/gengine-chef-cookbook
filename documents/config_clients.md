
# Client Nodes

↪ `recipes/config_clients.rb`

## Configuration

Grid Engine clients have the user-space tools installed and are used to manage jobs on the cluster. Often they are referred to as submit nodes. Use the Chef attribute `node.gengine.clients.nodes` to define submit nodes:

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

