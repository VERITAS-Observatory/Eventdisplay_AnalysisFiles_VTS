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
            # check log file for successful training
            for B in BDTDisp BDTDispError
            do
                if [[ -d ${IDIR}/${B} ]]; then
                    CHECKF=$(tail -n 1 ${IDIR}/${B}/mvaAngRes_${ZE}-${B}.log | grep -v Delete | wc -l)
                    if [[ $CHECKF != "0" ]]; then
                        echo "ERROR training file not complete in ${IDIR}/${B}/"
                    else
                        cp -v ${IDIR}/BDTDisp/*.xml ${ODIR}
                    fi
                else
                    echo "ERROR directory not found: ${IDIR}/${B}"
                fi
            done
        done
   done
done

