thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
srun --oversubscribe --partition=project --qos=maxjobs -n 1 -N 1 -c 12 $thisdir/buildInstall.sh $*
