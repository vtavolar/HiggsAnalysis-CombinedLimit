set -x 

folder=$1
card=$2
minbin=$3
maxbin=$4
npoints=$5
##eval otheropts="${6}"
##echo "AAAotheropts"
##echo "${otheropts}"

cd $folder

pwd

for bin in $(seq $minbin $maxbin); do 
    bin=r$bin
    label=$(echo $bin | sed 's%-%m%; s%\.%p%g')_ub_np${npoints}
    
    
    echo 'bash ../fit_bin_ub.sh  $card $label $bin $npoints "$otheropts" 2>&1 | tee fit_bin_$label.log & '
    bash ../fit_bin_ub.sh  $card $label $bin $npoints $6 2>&1 | tee fit_bin_$label.log &

done


wait
