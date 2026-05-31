#!/bin/bash
# copy dispBDT files from IRF production site
#
# hardwired
# - SIMTYPE (e.g., CARE_June2020)
# - ANALYSISTYPE (e.g., AP)
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"
# Set SIMTYPE to the desired simulation type (uncomment one):
# SIMTYPE="CARE_UV_2212"
# SIMTYPE="GRISU"
# SIMTYPE="CARE_RedHV"
# SIMTYPE="CARE_June2020"
# SIMTYPE="CARE_24_20"
# SIMTYPE="CARE_RedHV_Feb2024"
SIMTYPE="CARE_202404"

echo "COPY dispBDT for ${IRFVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"

ZAS=(00 20 30 35 40 45 50 55 60 65)
if [[ ${SIMTYPE} == "CARE_RedHV" ]]; then
    ZAS=(00 20 30 35 40 45 50 55)
fi

for Z in "${ZAS[@]}"
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
            # FIXEDEPOX EPOCHS="V6_2016_2017"
        fi
        for E in $EPOCHS
        do
            echo "EPOCH ${E} ATMO ${A}"
            if [[ ${SIMTYPE} == *"RedHV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_redHV/${Z}deg"
            elif [[ ${SIMTYPE} == *"UV"* ]]; then
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}_UV/${Z}deg"
            else
                ODIR="${VERITAS_ANALYSIS_TYPE:0:2}/${E}_${A}/${Z}deg"
            fi
            mkdir -p ${ODIR}
            IDIR="${VERITAS_IRFPRODUCTION_DIR}/${IRFVERSION}/${ANALYSISTYPE}/${SIMTYPE}"
            IDIR="${IDIR}/${E}_${A}_gamma/TMVA_AngularReconstruction"
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
