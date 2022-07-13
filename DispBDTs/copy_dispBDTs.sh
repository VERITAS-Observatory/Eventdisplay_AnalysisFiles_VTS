#!/bin/bash
# copy dispBDT files from IRF production site
#
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="TS"
SIMTYPE="CARE_June2020"

for Z in LZE MZE SZE
do
    if [[ $Z == "LZE" ]]; then
        ZE="60deg"
    elif [[ $Z == "MZE" ]]; then
        ZE="50deg"
    elif [[ $Z == "SZE" ]]; then
        ZE="20deg"
    fi
    echo $Z
    for A in ATM61 ATM62
    do
        if [[ ${A} == "ATM62" ]]; then
            EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
        else
            EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
        fi
        for E in $EPOCHS
        do
            ODIR="${E}_${A}/${Z}"
            mkdir -p ${ODIR}
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"
            IDIR="${IDIR}/${E}_${A}_gamma/TMVA_AngularReconstruction/"
            IDIR="${IDIR}/ze${ZE}/"
            if [[ -d ${IDIR} ]]; then
                cp -v ${IDIR}/BDTDisp/*.xml ${ODIR}
                cp -v ${IDIR}/BDTDispError/*.xml ${ODIR}
            fi
        done
   done
done

