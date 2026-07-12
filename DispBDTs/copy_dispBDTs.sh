#!/bin/bash
# copy dispBDT files from IRF production site
#

if [ "$#" -lt 1 ]; then
echo "
./copy_dispBDTs.sh <simulation type> [epochs (default: all)] [atmosphere (default \"61 62\")]

Copy dispBDT model files (stereo reconstruction)

   simulation types: CARE_202404 CARE_RedHV_Feb2024 CARE_RedHV CARE_UV_2212

"
exit
fi

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"
SIMTYPE="${1}"
EPOCHS=${2:-"all"}
ATM=${3:-"61 62"}

echo "COPY dispBDT for ${IRFVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"
echo "  Atmosphere $ATM"
echo "  EPOCHS $EPOCHS"

ZAS=(00 20 30 35 40 45 50 55 60 65)
if [[ ${SIMTYPE} == "CARE_RedHV" ]]; then
    ZAS=(00 20 30 35 40 45 50 55)
fi

for Z in "${ZAS[@]}"
do
    echo "Zenith bin $Z"
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
        LOCAL_A="${A}"
        if [[ ${SIMTYPE} == "GRISU" ]]; then
            LOCAL_A=${A/6/2}
        fi
        for E in $EPOCH_LIST
        do
            echo "EPOCH ${E} ATMO ${LOCAL_A}"
            if [[ ${SIMTYPE} == *"RedHV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}_redHV/${Z}deg"
            elif [[ ${SIMTYPE} == *"UV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}_UV/${Z}deg"
            else
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_ATM${LOCAL_A}/${Z}deg"
            fi
            mkdir -p "${ODIR}"
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"
            IDIR="${IDIR}/${E}_ATM${LOCAL_A}_gamma/TMVA_AngularReconstruction"
            IDIR="${IDIR}/ze${Z}deg/"
            # check log file for successful training
            for B in BDTDisp BDTDispError BDTDispSign BDTDispEnergy
            do
                echo "Parameters ${Z} ${B}"
                if [[ -d ${IDIR}/${B} ]]; then
                    CHECKF=$(grep -h "Delete method" "${IDIR}/${B}"/mvaAngRes_${Z}deg-${B}-Tel*.log 2>/dev/null | wc -l)
                    if [[ $CHECKF != "4" ]]; then
                        echo "ERROR training file(s) not complete in ${IDIR}/${B}/"
                    else
                        # expect 4=NTel xml files
                        NFILE=$(ls -1 ${IDIR}/${B}/*.xml | wc -l)
                        if [[ $NFILE == "4" ]]; then
                            cp -v -u ${IDIR}/${B}/*.xml ${ODIR}
                            cp -v -u ${IDIR}/${B}/*.log ${ODIR}
                            gzip -f -v ${ODIR}/*.xml
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
