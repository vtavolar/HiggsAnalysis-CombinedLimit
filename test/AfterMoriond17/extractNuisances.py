#!/usr/bin/env python2.7
###!/usr/bin/env python
# 
# --------------------------------------------
# Standard python import
from optparse import OptionParser, make_option
import fnmatch, glob, os, sys, json, itertools, array
import re
#sys.argv.append( '-b' )
from array import array
## ------------------------------------------------------------------------------------------------------------------------------------------------------



import os.path

xlabels={}


def getBinBoundariesFromDataset(dname):
    nameSplit = dname.split("_")
    genbinl=0.
    genbinh=0.
    recobinl=0.
    recobinh=0.
    for ip in range(len(nameSplit)):
        if "gen" in nameSplit[ip] or "Gen" in nameSplit[ip]:
            if(len(nameSplit)>ip+1):
                genbinl = float(nameSplit[ip+1].replace("m","-").replace("p","."))
                genbinh = float(nameSplit[ip+2].replace("m","-").replace("p","."))
        if "reco" in nameSplit[ip] or "Reco" in nameSplit[ip]:
            if(len(nameSplit)>ip+1):
                recobinl = float(nameSplit[ip+1].replace("m","-").replace("p","."))
                recobinh = float(nameSplit[ip+2].replace("m","-").replace("p","."))
    return [genbinl,genbinh],[recobinl,recobinh]

def getBinBoundariesFromProcess(dname):
    nameSplit = dname.split("_")
    genbinl=0.
    genbinh=0.
    for ip in range(len(nameSplit)):
        if "gen" in nameSplit[ip] or "Gen" in nameSplit[ip]:
            if(len(nameSplit)>ip+1):
                genbinl = float(nameSplit[ip+1].replace("m","-").replace("p","."))
                genbinh = float(nameSplit[ip+2].replace("m","-").replace("p","."))
    return [genbinl,genbinh]

def getVarsName(dname):
    nameSplit = dname.split("_")
    genVar=""
    recoVar=""
    for ip in range(len(nameSplit)):
        if "gen" in nameSplit[ip] or "Gen" in nameSplit[ip]:
            genVar=nameSplit[ip]
        if "reco" in nameSplit[ip] or "Reco" in nameSplit[ip]:
            recoVar=nameSplit[ip]
    return genVar,recoVar
    
def mapPOItoProcess(line):
    POItoProc={}
    for s in filter(None,line.strip(' ').split("--PO")):
        print s.strip()
        print s.strip().split(":")
        print s.strip().split(":")[0].split("/")
        print s.strip().split(":")[1].split("[")
        POItoProc[s.strip().split(":")[1].split("[")[0]] = getBinBoundariesFromProcess( s.strip().split(":")[0].split("/")[1] )
    return POItoProc

def getBestFit(POIs, lines):
    BF={}
    for POI in POIs:
        for line in lines:
            if POI in line:
                print "".join(line.split())
                BF[POI]= re.split('[\+-]', (("".join(line.split())).split(POI+":")[1].strip()))
    for POI in POIs:
        if POI not in BF.keys():
            BF[POI]=[0.0,1.0,1.0]
    return BF
    
    
            
def main(o,args):
    nuis=[]
    with open(options.files) as f:
        content = f.readlines()
    for line in content:
        if 'param' in line.split() or 'lnN' in line.split():
            nuis.append(line.split()[0])
    freezeExpr = ",".join(nuis)
#    print nuis
    print freezeExpr
## ------------------------------------------------------------------------------------------------------------------------------------------------------    
if __name__ == "__main__":
    parser = OptionParser(option_list=[
            make_option("-i", "--indir",
                        action="store", type="string", dest="indir",
                        default="./",
                        help="input directory", metavar="DIR"
                        ),
            make_option("-f", "--files",
                        action="store", type="string", dest="files",
                        default="allSig125IA.root",
                        help="pattern of files to be read", metavar="PATTERN"
                        )
            ])

    (options, args) = parser.parse_args()

    sys.argv.append("-b")
    main(options, args)






