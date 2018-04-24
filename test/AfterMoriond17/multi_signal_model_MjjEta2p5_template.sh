##
##cd pt_moriond17
## 
## text2workspace.py -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel  --PO verbose \
##     --PO 'map=.*/InsideAcceptance_genPt_0p0to15p0:r0[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_15p0to30p0:r1[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_30p0to45p0:r2[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_45p0to85p0:r3[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_85p0to125p0:r4[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_125p0to200p0:r5[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_200p0to350p0:r6[1,0,2]' \
##     --PO 'map=.*/InsideAcceptance_genPt_350p0to10000p0:r7[1,0,2]' \
##     -o Datacard_13TeV_differential_pT_moriond17_reminiaod_extrabin.root Datacard_13TeV_differential_pT_moriond17_reminiaod_extrabin.txt
##
#### combine -M MultiDimFit -t -1 --saveWorkspace -n asimov_fit --setPhysicsModelParameters r0=1,r1=1,r2=1,r3=1,r4=1,r5=1,r6=1 -m 125 --minimizerStrategy 2 Datacard_13TeV_differential_pT_moriond17.root
#### mv higgsCombineasimov_fit.MultiDimFit.mH125.root Datacard_13TeV_differential_pT_moriond17_post_asmov_fit.root
## 
### combine -M GenerateOnly --setPhysicsModelParameters r0=1,r1=1,r2=1,r3=1,r4=1,r5=1,r6=1 -n asimov_toy -m 125  --saveToys -t -1 --snapshotName MultiDimFit Datacard_13TeV_differential_pT_moriond17_post_asmov_fit.root &
##
#### combine -M MultiDimFit --setPhysicsModelParameters r0=1,r1=1,r2=1,r3=1,r4=1,r5=1,r6=1 -n asimov_toy_best_fit -m 125 -t -1 --snapshotName MultiDimFit Datacard_13TeV_differential_pT_moriond17_post_asmov_fit.root &
##
##cd -

DIR=$1 
DATACARD=$2
#IFS=',' read -r -a POIS <<<$3
POIS=(`echo $3 | tr "," " "`)

printf "[%s]\n" "${POIS[@]}"

RANGE=""
NPOINTS=""
if ! [ -z $4 ]; then
    RANGE=$4
    NPOINTS=$5
else
    RANGE="[1,0.0,2.0]"
    NPOINTS="20"
fi

#IFS=$'\n' SORTEDPOIS=($(sort <<<"${POIS[*]}"))
#unset IFS

DCROOT=${DATACARD%".txt"}.root
DCPOSTFIT=${DATACARD%".txt"}_post_asimov_fit.root

echo $DATACARD
echo $DCROOT
echo $DCPOSTFIT
echo "THE DIR"
echo $DIR

cd $DIR
echo $PWD

echo "RANGE"
echo ${RANGE}
echo "NPOINTS"
echo ${NPOINTS}

POISTRING=""
SETPOIS=""
REDEFINEPOIS=""
echo "size of pois"
echo ${#POIS[@]}
for index in "${!POIS[@]}"
do
    POISTRING=${POISTRING}" --PO 'map=.*/${POIS[index]}:r${index}[${RANGE}]' "
    SETPOIS=${SETPOIS}"r${index}=1,"
    REDEFINEPOIS=${REDEFINEPOIS}"r${index},"
done
REDEFINEPOIS=${REDEFINEPOIS}"MH"

SETPOIS=${SETPOIS%","}
echo $POISTRING
echo $SETPOIS
echo $REDEFINEPOIS

set -x
t2w="text2workspace.py -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel  --PO verbose ${POISTRING}      --PO 'higgsMassRange=123,127'   -o ${DCROOT} ${DATACARD}"
text2workspace.py -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel  --PO verbose ${POISTRING}      --PO 'higgsMassRange=123,127'   -o $DCROOT $DATACARD
eval $t2w
#    --PO 'map=.*/InsideAcceptance_genMjjEta2p5_0p0_120p0:r0[1,0.0,2.0]' \
#    --PO 'map=.*/InsideAcceptance_genMjjEta2p5_120p0_450p0:r1[1,0.0,2.0]' \
#    --PO 'map=.*/InsideAcceptance_genMjjEta2p5_450p0_1000p0:r2[1,0.0,2.0]' \
#    --PO 'map=.*/InsideAcceptance_genMjjEta2p5_1000p0_13000p0:r3[1,0.0,2.0]' 
#${POISTRING} \
#    --PO 'higgsMassRange=123,127' \
#  -o $DCROOT $DATACARD


combine -M GenerateOnly -t -1 --saveToys --saveWorkspace -n AsimovPreFit --setPhysicsModelParameters ${SETPOIS} -m 125  $DCROOT 

combine -M MultiDimFit -t -1 --toysFile higgsCombineAsimovPreFit.GenerateOnly.mH125.123456.root --saveWorkspace -n AsimovBestFit --setPhysicsModelParameters ${SETPOIS} -m 125 --minimizerStrategy 2 $DCROOT 
mv higgsCombineAsimovBestFit.MultiDimFit.mH125.root $DCPOSTFIT

combine -M GenerateOnly -t -1 --saveToys --saveWorkspace --snapshotName MultiDimFit -n AsimovPostFit --setPhysicsModelParameters ${SETPOIS} -m 125 $DCPOSTFIT

combine -M MultiDimFit  --saveWorkspace -n DataBestFit --setPhysicsModelParameters ${SETPOIS} --setPhysicsModelParameterRanges MH=123,127 --redefineSignalPOIs=${REDEFINEPOIS} --floatNuisances MH -m 125 --minimizerStrategy 2 ${DCROOT}  2>&1| tee multiDimFit_ub.out 

echo "pwd before extractNuisances"
echo $PWD
NUIS=`python ../extractNuisances.py -f ${DATACARD}`
echo "NUISANCES1"
echo $NUIS

cd - 
##bash fit_bins.sh $DIR $DCPOSTFIT 0 ${#POIS[@]} ${NPOINTS} & 
##bash fit_bins_freezeSysts.sh $DIR $DCPOSTFIT 0 ${#POIS[@]} ${NPOINTS} $NUIS & 

bash fit_bins_ub.sh $DIR $DCROOT 0 ${#POIS[@]} ${NPOINTS} & 
bash fit_bins_ub_freezeSysts.sh $DIR higgsCombineDataBestFit.MultiDimFit.mH125.root 0 ${#POIS[@]} ${NPOINTS} $NUIS & 
wait

thisdir=$PWD

cd /mnt/t3nfs01/data01/shome/vtavolar/FinalFits/CMSSW_7_1_5/src/flashggFinalFit/Plots/FinalResults/
#source /cvmfs/cms.cern.ch/cmsset_default.sh
#eval `scramv1 runtime -sh` 
for index in "${!POIS[@]}"
do
    echo "doing plots..."
#    python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner${index}_np${NPOINTS}.MultiDimFit.mH125.root --mu --muExpr "r${index}" -o scan_${DIR}_np${NPOINTS}_r${index} | tee scan_${DIR}_np${NPOINTS}_r${index}.log
#    python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner${index}_np${NPOINTS}_freezeNuis.MultiDimFit.mH125.root --mu --muExpr "r${index}" -o scan_${DIR}_np${NPOINTS}_freezeNuis_r${index} | tee scan_${DIR}_np${NPOINTS}_freezeNuis_r${index}.log

    python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner${index}_ub_np${NPOINTS}.MultiDimFit.mH120.root --mu --muExpr "r${index}" -o scan_${DIR}_ub_np${NPOINTS}_r${index} | tee scan_${DIR}_ub_np${NPOINTS}_r${index}.log
    python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner${index}_np${NPOINTS}_ub_freezeNuis.MultiDimFit.mH125.root --mu --muExpr "r${index}" -o scan_${DIR}_np${NPOINTS}_ub_freezeNuis_r${index} | tee scan_${DIR}_np${NPOINTS}_ub_freezeNuis_r${index}.log

done

grep -i "best fit" scan_${DIR}_np${NPOINTS}_r*.log | tee expectedPrecision_${DIR}_np${NPOINTS}.txt
echo ${POISTRING} >> expectedPrecision_${DIR}_np${NPOINTS}.txt

grep -i "best fit" scan_${DIR}_np${NPOINTS}_freezeNuis_r*.log | tee expectedPrecision_${DIR}_np${NPOINTS}_freezeNuis.txt
echo ${POISTRING} >> expectedPrecision_${DIR}_np${NPOINTS}_freezeNuis.txt

grep -i "best fit" scan_${DIR}_ub_np${NPOINTS}_r*.log | tee expectedPrecision_${DIR}_ub_np${NPOINTS}.txt
echo ${POISTRING} >> expectedPrecision_${DIR}_ub_np${NPOINTS}.txt

grep -i "best fit" scan_${DIR}_np${NPOINTS}_ub_freezeNuis_r*.log | tee expectedPrecision_${DIR}_np${NPOINTS}_ub_freezeNuis.txt
echo ${POISTRING} >> expectedPrecision_${DIR}_np${NPOINTS}_ub_freezeNuis.txt

###python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner0_np40.MultiDimFit.mH125.root --mu --muExpr "r0" -o scan_${DIR}_np40_r0
###python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner1_np40.MultiDimFit.mH125.root --mu --muExpr "r1" -o scan_${DIR}_np40_r1
###python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner2_np40.MultiDimFit.mH125.root --mu --muExpr "r2" -o scan_${DIR}_np40_r2
###python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner3_np40.MultiDimFit.mH125.root --mu --muExpr "r3" -o scan_${DIR}_np40_r3
###python makeCombinePlots.py  -b -f $thisdir/$DIR/higgsCombiner4_np40.MultiDimFit.mH125.root --mu --muExpr "r4" -o scan_${DIR}_np40_r4



mkdir -p /afs/cern.ch/user/v/vtavolar/www/DiffHggPt/outdir_Differential_SignalModel_ICHEPconditions_1bis_newphp/afterMoriond17/outdir_${DIR}
cp scan*${DIR}* /afs/cern.ch/user/v/vtavolar/www/DiffHggPt/outdir_Differential_SignalModel_ICHEPconditions_1bis_newphp/afterMoriond17/outdir_${DIR}

cd -