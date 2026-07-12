#!/bin/bash
# copy dispXGB model files from IRF production site
# Stereo and gamma/hadron analysis
#

if [ "$#" -lt 1 ]; then
echo "
./copy_dispXGB.sh <simulation type> [epochs (default: all)] [atmosphere (default \"61 62\")]

   Copy dispXGB model files (stereo reconstruction, classification)

   simulation types: CARE_202404 CARE_RedHV_Feb2024

"
exit
fi

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"
SIMTYPE="${1}"
EPOCHS=${2:-"all"}
ATM=${3:-"61 62"}

echo "COPY dispXGB  for ${IRFVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"
echo "  Atmosphere $ATM"
echo "  EPOCHS $EPOCHS"

STEREO_PAR="$VERITAS_EVNDISP_AUX_DIR/ParameterFiles/XGB-stereo-parameter.json"
IDS=$(jq -r '.zenith[].id' $STEREO_PAR)
echo "Zenith bins: $IDS"

for A in $ATM
do
    if [[ $EPOCHS == "all" ]]; then
        if [[ ${SIMTYPE} == "GRISU" ]]; then
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
        fi
    fi
    A="ATM${A}"
    if [[ ${SIMTYPE} == "GRISU" ]]; then
        A=${A/6/2}
    fi
    for E in $EPOCHS
    do
        echo "EPOCH ${E} ATMO ${A}"
        if [[ ${SIMTYPE} == *"RedHV"* ]]; then
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_redHV"
        elif [[ ${SIMTYPE} == *"UV"* ]]; then
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_UV"
        else
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}"
        fi
        IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"

        ##################################################
        # Stereo analysis
        for Z in $IDS
        do
            echo "Zenith bin $Z"
            ZDIR="${ODIR}/${Z}"
            mkdir -p ${ZDIR}
            SDIR="${IDIR}/${E}_${A}_gamma/TrainXGBStereoAnalysis/${Z}"
            cp -v -f ${SDIR}/* ${ZDIR}/
        done

        ##################################################
        # Gamma/hadron BDTs (zenith angle independent)
        GDIR="${IDIR}/${E}_${A}_gamma/TrainXGBGammaHadron"
        cp -v -f ${GDIR}/*.{joblib,log} ${ODIR}/
    done
done
