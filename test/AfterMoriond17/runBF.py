import os

extensions={}
extensions["InclusiveNNLOPS"]=1
extensions["Njets2p5NNLOPS"]=5
extensions["Jet2p5Pt0NNLOPS_newBins"]=6
extensions["Jet2p5AbsRapidity0NNLOPS_newBins"]=5
extensions["AbsDeltaPhiGgJet0Eta2p5NNLOPS_newBins"]=5
extensions["AbsDeltaRapidityGgJet0Eta2p5NNLOPS"]=5
extensions["Jet4p7Pt1NNLOPS_tightJetPuId"]=4
extensions["Jet4p7AbsRapidity1NNLOPS_tightJetPuId"]=4
extensions["AbsDeltaPhiJjEta4p7NNLOPS_tightJetPuId"]=4
extensions["AbsDeltaPhiGgJjEta4p7NNLOPS_tightJetPuId"]=4
extensions["ZeppenfeldEta4p7NNLOPS_tightJetPuId"]=4
extensions["MjjEta4p7NNLOPS_newBins_tightJetPuId"]=6
extensions["AbsDeltaEtaJJEta4p7NNLOPS_tightJetPuId"]=4
extensions["Jet4p7Pt1VBFlikeNNLOPS_tightJetPuId"]=4
extensions["AbsDeltaPhiJjEta4p7VBFlikeNNLOPS_tightJetPuId"]=4
extensions["AbsDeltaPhiGgJjEta4p7VBFlikeNNLOPS_tightJetPuId"]=4
extensions["PtNjets2p5NNLOPS_newBins_v2"]=9
extensions["PtNNLOPS_newBins"]=8
extensions["AbsRapidityNNLOPS_newBins"]=5
extensions["CosThetaStarNNLOPS"]=5
extensions["METNNLOPS_newBins_v2"]=3
extensions["NjetsBflavorTight2p5NNLOPS"]=3
extensions["NleptonsNNLOPS"]=3
extensions["1LeptonHighMETNNLOPS"]=2
extensions["1LeptonLowMETNNLOPS"]=2
extensions["1Lepton1BjetNNLOPS"]=2

for EXT in extensions.keys():
    setPhysParam=""
    POIs=""
    for r in range(extensions[EXT]):
        setPhysParam=setPhysParam+"r%s=1," % r
        POIs=POIs+"r%s," % r
    setPhysParam=setPhysParam.rstrip(',')
    POIs=POIs+"MH"
    os.system("pwd")
    os.chdir("differential_%s" % EXT)
    os.system("pwd")
    print "combine -M MultiDimFit  --saveWorkspace -n %s_bestfit --setPhysicsModelParameters %s --setPhysicsModelParameterRanges MH=123,127 --redefineSignalPOIs=%s --floatNuisances MH -m 125 --minimizerStrategy 2 Datacard_13TeV_differential_%s.root | tee multiDimFit_ub.out" % (EXT,setPhysParam, POIs,EXT)
    os.system("combine -M MultiDimFit  --saveWorkspace -n %s_bestfit --setPhysicsModelParameters %s --setPhysicsModelParameterRanges MH=123,127 --redefineSignalPOIs=%s --floatNuisances MH -m 125 --minimizerStrategy 2 Datacard_13TeV_differential_%s.root | tee multiDimFit_ub.out" % (EXT,setPhysParam, POIs,EXT))
    os.chdir("..")
