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
