

List the jobs running on localhost: 

    qhost -h $(hostname -f) -j -q

**Disable all queues** on localhost:

    qmod -d *@$(hostname -f)

Submit a test jobs to a specific node:

    qsub -l hostname=$FQDN

Display only disabled queues with jobs still running: 

    qstat -f -qs d -ne | grep -v "^--"


