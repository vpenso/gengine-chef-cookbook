
↪ `recipes/config_global.rb`  
↪ `attributes/config_global.rb`

## Global Configuration

Grid Engine has a global configuration defining defaults for the entire system. The manual `sge_conf` describes all available configurations in detail. 

    » qconf -sconf global
    execd_spool_dir              /var/spool/gridengine/execd
    mailer                       /usr/bin/mail
    xterm                        /usr/bin/xterm
    load_sensor                  none
    prolog                       none
    epilog                       none
    [...SNIP...]

Use the attribute `node.gengine.global` to overwrite the cookbook defaults. 

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

The global configuration can be altered by a file called `global` in the configuration repository. Such a configuration looks like:

    #global:
    ...SNIP...
    login_shells                 zsh,bash,sh
    gid_range                    65400-66500
    ...SNIP...

