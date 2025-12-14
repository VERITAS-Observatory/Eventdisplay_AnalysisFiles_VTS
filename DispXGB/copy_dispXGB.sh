#!/bin/bash
# copy dispXGB files from IRF production site
#
# hardwired
# - SIMTYPE (e.g., CARE_June2020)
# - ANALYSISTYPE (e.g., AP)
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"
SIMTYPE="CARE_UV_2212"
SIMTYPE="GRISU"
SIMTYPE="CARE_RedHV"
SIMTYPE="CARE_June2020"
SIMTYPE="CARE_24_20"
SIMTYPE="CARE_RedHV_Feb2024"
SIMTYPE="CARE_202404"

echo "COPY dispXGB  for ${IRVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"

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
        if [[ ${SIMTYPE} == "GRISU" ]]; then
            A=${A/6/2}
            EPOCHS="V4 V5"
        elif [[ ${SIMTYPE} == *"UV"* ]]; then
            EPOCHS=$(cat ../IRF_EPOCHS_obsfilter.dat | sort -u)
            if [[ ${A} == "ATM62" ]]; then
                continue
            fi
        else
            if [[ ${A} == "ATM62" ]]; then
                EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
            else
                EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
            fi
            EPOCHS="V6_2016_2017"
        fi
        for E in $EPOCHS
        do
            echo "EPOCH ${E} ATMO ${A} (**NOTE EPOCHS ARE IGNORED**)"
            if [[ ${SIMTYPE} == *"RedHV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_redHV/${Z}"
            elif [[ ${SIMTYPE} == *"UV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_UV/${Z}"
            else
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}/${Z}"
            fi
            mkdir -p ${ODIR}
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"
            IDIR="${IDIR}/${E}_${A}_gamma/TrainXGB/ze${ZE}"
            cp -v -i ${IDIR}/* ${ODIR}/
        done
   done
done
