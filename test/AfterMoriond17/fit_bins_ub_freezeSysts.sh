set -x 

folder=$1
card=$2
minbin=$3
maxbin=$4
npoints=$5
nuis=$6
echo "NUISANCES"
echo $nuis
##eval otheropts="${6}"
##echo "AAAotheropts"
##echo "${otheropts}"

cd $folder

pwd

for bin in $(seq $minbin $maxbin); do 
    bin=r$bin
    label=$(echo $bin | sed 's%-%m%; s%\.%p%g')_np${npoints}_ub_freezeNuis
    
    
    echo 'bash ../fit_bin_ub_freezeSysts.sh  $card $label $bin $npoints $nuis 2>&1 | tee fit_bin_ub_$label.log & '
    bash ../fit_bin_ub_freezeSysts.sh  $card $label $bin $npoints $nuis 2>&1 | tee fit_bin_ub_$label.log &

done


wait
