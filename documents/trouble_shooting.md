
Show finished jobs from a user:

    qacct -o $USER -j -d 1

List all pending jobs:

    qstat -s p -u \* 

List the reason why a jobs isn't dispatched:

    qalter -w v $JOBID

List the jobs running on localhost: 

    qhost -h $(hostname -f) -j -q

**Disable all queues** on localhost:

    qmod -d *@$(hostname -f)

Clear all jobs an re-schedule them:

    qmod -cj '*'

Submit a test jobs to a specific node:

    qsub -l hostname=$FQDN

Display only disabled queues with jobs still running: 

    qstat -f -qs d -ne | grep -v "^--"


