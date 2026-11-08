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
IDS=$(jq -r '.zenith[].id' "$STEREO_PAR")
echo "Zenith bins: $IDS"
CLASSIFY_PAR="$VERITAS_EVNDISP_AUX_DIR/ParameterFiles/XGB-classify-parameter.json"
N_GH_EBINS=$(jq -r '.energy_bins_log10_tev | length' "$CLASSIFY_PAR")
echo "Gamma/hadron energy bins: $N_GH_EBINS"

FAILURES=0

# check that a model exists as <prefix>.joblib.gz or <prefix>.joblib
check_model()
{
    if [[ ! -f "${1}.joblib.gz" ]] && [[ ! -f "${1}.joblib" ]]; then
        echo "ERROR: missing model ${1}.joblib(.gz)"
        FAILURES=$((FAILURES + 1))
    fi
}

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
            mkdir -p "${ZDIR}"
            SDIR="${IDIR}/${E}_ATM${LOCAL_A}_gamma/TrainXGBStereoAnalysis/${Z}"
            cp -v -f "${SDIR}"/* "${ZDIR}"/
            check_model "${ZDIR}/dispdir_bdt"
        done

        ##################################################
        # Gamma/hadron BDTs (zenith angle independent)
        # (training writes gammahadron_bdt_ebin<N>.joblib.gz)
        GDIR="${IDIR}/${E}_ATM${LOCAL_A}_gamma/TrainXGBGammaHadron"
        if [[ ! -d "${GDIR}" ]]; then
            echo "No gamma/hadron models for epoch ${E} (${GDIR} not found)"
            continue
        fi
        mkdir -p "${ODIR}"
        for F in "${GDIR}"/*.joblib.gz "${GDIR}"/*.joblib "${GDIR}"/*.log; do
            [[ -f "$F" ]] && cp -v -f "$F" "${ODIR}"/
        done
        for (( B=0; B<N_GH_EBINS; B++ )); do
            check_model "${ODIR}/gammahadron_bdt_ebin${B}"
        done
    done
done

if [[ $FAILURES -gt 0 ]]; then
    echo "ERROR: ${FAILURES} expected model file(s) missing after copy"
    exit 1
fi
echo "All expected model files copied."
