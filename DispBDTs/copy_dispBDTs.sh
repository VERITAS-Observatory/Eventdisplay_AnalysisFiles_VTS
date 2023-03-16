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
SIMTYPE="CARE_RedHV"

echo "COPY dispBDT for ${IRVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"

for Z in XZE LZE MZE SZE
do
    if [[ $Z == "XZE" ]]; then
        ZE="60deg"
        if [[ ${SIMTYPE} == "CARE_RedHV" ]]; then
            ZE="55deg"
        fi
    elif [[ $Z == "LZE" ]]; then
        ZE="55deg"
    elif [[ $Z == "MZE" ]]; then
        ZE="45deg"
    elif [[ $Z == "SZE" ]]; then
        ZE="20deg"
    fi
    echo "Zenith bin $Z $ZE"
    for A in ATM61 ATM62
    do
        if [[ ${SIMTYPE} == "CARE_RedHV" ]]; then
            if [[ ${A} == "ATM62" ]]; then
                continue
            fi
            EPOCHS=$(cat ../IRF_EPOCHS_*.dat | sort -u)
        else
            if [[ ${A} == "ATM62" ]]; then
                EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
            else
                EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
            fi
        fi
        for E in $EPOCHS
        do
            echo "EPOCH ${E}"
            if [[ ${SIMTYPE} == *"RedHV"* ]]; then
                ODIR="${E}_${A}_${ANALYSISTYPE}_redHV/${Z}"
            else
                ODIR="${E}_${A}_${ANALYSISTYPE}/${Z}"
            fi
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
