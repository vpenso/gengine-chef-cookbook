
# Fair-Share (Dynamic Resource Management)

↪ `recipes/config_sharetree.rb`

## Basics

By default the scheduler operates as FIFO, executing jobs in order of submission. In case of dynamic scheduling the job priorities (read the manual `sge_priority`) are determined based on the following strategies:

2. The **functional policy** distributes resources strictly among users, projects and departments. Assing functional tickets to users with `enforce_user auto` and `auto_users_fshare 100` in the global configuration. Adjust the relative importance with `weight_tickets_functional 10000` in the scheduler configuration.  
3. The **share-based policy** (aka. Fair-Share) considers past and current resource consumption when making scheduling decisions. A `sharetree` defines user and project shares for the scheduler as tragets for an average resource assignment over time.  The `compensation_factor` limits how much a user/project can dominate the resources in the near term. For example a factor of two would allow a user/project to use twice its long-term resource limit. A factor of zero means not compensation, and one takes no effect. The `halftime` defines a decay factor to reduce the impact of past resource consumption. Define the realtive importance of Fair-Share with `weight_tickets_share 1000000`.
4. The **overwrite policy** grants precedence for users and jobs. Enable this policy by setting `share_override_tickets` to true and by assigning "otickets" to users, projects or departments. (Use `qalter` to assign overwrite tickets to pending jobs.)

Any combination and order can be configured with the `policy_hierarchy` attribute using the first letters `[O][S|F]`. All policies are defined using "tickets", which will be assigned to jobs in order to lift its priority. The total number of tickets in the scheduling process is controlled by the administrator. The relative number of tickets available to each policy determines its "importance". (Disable a policy by assigning zero tickets to it.)

The fair-share configuration is displayed with `qconf -sstree`. Clear the sharetree (for all users and projects) with `qconf -clearusage`. 

## Configuration

Buy default the _gengine_ cookbook will deploy a fair-share configuration to equally distribute all resources among user, groups and projects. In case you don't want the "sharetree" to be modified by the cookbook comment the including of the recipe in `recipes/install_master.rb`.

In order **to deploy a more complex configuration for fair-share use a file `sharetree` in the configuration repository**. This will overwrite the default from the cookbook. Inspect the sharetree on a deployed master with the command `qconf -sstree`. The syntax of the sharetree file is explained in the **manual "share_tree"**.

