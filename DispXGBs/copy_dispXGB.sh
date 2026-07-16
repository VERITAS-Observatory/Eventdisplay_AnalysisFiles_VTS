#!/bin/bash
# copy dispXGB model files (stereo reconstruction, classification) from IRF production site
#

if [ "$#" -lt 1 ]; then
echo "
./copy_dispXGB.sh <simulation type> [epochs (default: all)] [atmosphere (default \"61 62\")]

   Copy dispXGB model files (stereo reconstruction, classification)

   simulation types: CARE_202404 CARE_RedHV_Feb2024 CARE_RedHV CARE_UV_2212

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
    EPOCH_LIST="${EPOCHS}"
    if [[ $EPOCHS == "all" ]]; then
        if [[ ${SIMTYPE} == "GRISU" ]]; then
            EPOCH_LIST="V4 V5"
        elif [[ ${SIMTYPE} == *"UV"* ]]; then
            EPOCH_LIST=$(cat ../IRF_EPOCHS_obsfilter.dat | sort -u)
            if [[ ${A} == "62" ]]; then
                continue
            fi
        else
            if [[ ${A} == "62" ]]; then
                EPOCH_LIST=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
            else
                EPOCH_LIST=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
            fi
        fi
    fi
    LOCAL_A="${A}"
    if [[ ${SIMTYPE} == "GRISU" ]]; then
        LOCAL_A=${A/6/2}
    fi
    for E in $EPOCH_LIST
    do
        echo "EPOCH ${E} ATMO ${LOCAL_A}"
        if [[ ${SIMTYPE} == *"RedHV"* ]]; then
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}_redHV"
        elif [[ ${SIMTYPE} == *"UV"* ]]; then
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}_UV"
        else
            ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}"
        fi
        IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"

        ##################################################
        # Stereo analysis
        for Z in $IDS
        do
            echo "Zenith bin $Z"
            ZDIR="${ODIR}/${Z}"
            mkdir -p ${ZDIR}
            SDIR="${IDIR}/${E}_ATM${LOCAL_A}_gamma/TrainXGBStereoAnalysis/${Z}"
            cp -v -f ${SDIR}/* ${ZDIR}/
        done

        ##################################################
        # Gamma/hadron BDTs (zenith angle independent)
        GDIR="${IDIR}/${E}_ATM${LOCAL_A}_gamma/TrainXGBGammaHadron"
        cp -v -f ${GDIR}/*.{joblib,log} ${ODIR}/
    done
done
