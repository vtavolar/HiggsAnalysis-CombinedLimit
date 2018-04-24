#!/bin/env python

import sys
import os

if len(sys.argv) < 3: 
    print "usage: %s <output> <input1> [input2] ..."
    sys.exit(-1)

output=sys.argv[1]
inputs=sys.argv[2:]

if os.path.exists(output):
    print "output file already exists"
    sys.exit(-1)

import ROOT as RT

RT.RooMsgService.instance().setGlobalKillBelow(RT.RooFit.WARNING)

def getWs(fname,wsname="wsig_13TeV"):
    fin = RT.TFile.Open(fname)
    return fin.Get(wsname)
    

workspaces=map(getWs, inputs)

ws0 = workspaces[0]

for (iws,ws) in enumerate(workspaces[1:]):
    print(inputs[iws+1])
    pdfs = ws.allPdfs()
    pditr = pdfs.createIterator()
    pdf = pditr.Next()
    while pdf:
        if not "allProcs" in pdf.GetName(): 
            # print(pdf.GetName())
            getattr(ws0,"import")(pdf,RT.RooFit.RecycleConflictNodes())
        pdf = pditr.Next()

    funcs = ws.allFunctions()
    funitr = funcs.createIterator()
    func = funitr.Next()
    while func:
        if not "allProcs" in func.GetName(): 
            # print(func.GetName())
            getattr(ws0,"import")(func,RT.RooFit.RecycleConflictNodes())
        func = funitr.Next()

ws0.writeToFile(output)
