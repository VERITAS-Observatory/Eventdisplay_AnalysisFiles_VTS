#!/bin/bash
# copy dispXGB model files from IRF production site
# Stereo and gamma/hadron analysis
#
# hardwired
# - SIMTYPE (e.g., CARE_June2020)
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

echo "COPY dispXGB  for ${IRFVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"

STEREO_PAR="$VERITAS_EVNDISP_AUX_DIR/ParameterFiles/XGB-stereo-parameter.json"
IDS=$(jq -r '.zenith[].id' $STEREO_PAR)
for Z in $IDS
do
    echo "Zenith bin $Z"
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
            # TODO fixed epoch
            EPOCHS="V6_2016_2017"
        fi
        for E in $EPOCHS
        do
            echo "EPOCH ${E} ATMO ${A} (**NOTE EPOCHS ARE IGNORED**)"
            if [[ ${SIMTYPE} == *"RedHV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_redHV"
            elif [[ ${SIMTYPE} == *"UV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_UV"
            else
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}"
            fi
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"

            # Stereo analysis
            ZDIR="${ODIR}/${Z}"
            mkdir -p ${ZDIR}
            SDIR="${IDIR}/${E}_${A}_gamma/TrainXGBStereoAnalysisBinned/${Z}"
            cp -v -i ${SDIR}/* ${ZDIR}/

            # Gamma/hadron BDTs (zenith angle independent)
            if [[ $Z == "SZE" ]]; then
                GDIR="${IDIR}/${E}_${A}_gamma/TrainXGBGammaHadron"
                cp -v -i ${GDIR}/*.{joblib,log} ${ODIR}/
            fi
        done
   done
done
