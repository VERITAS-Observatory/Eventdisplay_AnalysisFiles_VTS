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
        ZE="30deg"
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
            echo "EPOCH ${E}"
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
                        # expect 4=NTel xml files
                        NFILE=$(ls -1 ${IDIR}/${B}/*.xml | wc -l)
                        if [[ $NFILE == "4" ]]; then
                            cp -v -u ${IDIR}/${B}/*.xml ${ODIR}
                        else
                            echo "ERROR found only $NFILE xml files (expected 4) in ${IDIR}/${B}/"
                        fi
                    fi
                else
                    echo "ERROR directory not found: ${IDIR}/${B}"
                fi
            done
        done
   done
done
