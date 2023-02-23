#!/bin/bash
# copy dispBDT files from IRF production site
#
# hardwired 
# - SIMTYPE (e.g., CARE_June2020)
# - ANALYSISTYPE (e.g., AP)
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="AP"
SIMTYPE="CARE_June2020"

echo "COPY dispBDT for ${IRVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"

for Z in XZE LZE MZE SZE
do
    if [[ $Z == "XZE" ]]; then
        ZE="60deg"
    elif [[ $Z == "LZE" ]]; then
        ZE="55deg"
    elif [[ $Z == "MZE" ]]; then
        ZE="45deg"
    elif [[ $Z == "SZE" ]]; then
        ZE="20deg"
    fi
    echo $Z
    # for A in ATM61 ATM62
    for A in ATM62
    do
        if [[ ${A} == "ATM62" ]]; then
            EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
        else
            EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
        fi
#        for E in $EPOCHS
        for E in "V6_2022_2022s"
        do
            echo "EPOCH ${E}"
            ODIR="${E}_${A}_${ANALYSISTYPE}/${Z}"
            mkdir -p ${ODIR}
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"
            IDIR="${IDIR}/${E}_${A}_gamma/TMVA_AngularReconstruction/"
            IDIR="${IDIR}/ze${ZE}/"
            # check log file for successful training
            for B in BDTDisp BDTDispError BDTDispSign
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
                            cp -v -u ${IDIR}/${B}/*.log ${ODIR}
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
