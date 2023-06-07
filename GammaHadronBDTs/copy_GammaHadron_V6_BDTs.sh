#!/bin/bash
# copy gamma/hadron BDT files from IRF production site
#
# hardwired 
# - ANALYSISTYPE (e.g., AP)
# - Directory with BDT output
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"

BDTDIR="$VERITAS_USER_DATA_DIR/analysis/Results/v490/AP/BDTtraining/GammaHadronBDTs_V6_DISP/"

echo "COPY gamma/hadron BDTs for ${IRVERSION}, analysis type ${ANALYSISTYPE}"
echo "  reading files from ${BDTDIR}"

for A in ATM61 ATM62
do
    if [[ ${A} == "ATM62" ]]; then
        EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
    else
        EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
    fi
    for E in $EPOCHS
    do
        for C in NTel2-Moderate NTel2-Soft NTel3-Hard
        do
            echo "EPOCH ${E} CUT ${C}"
            ODIR="${E}_${A}/${C}"
            if [[ ! -d ${BDTDIR}/${ODIR} ]]; then
                echo "   directory not found"
                continue
            fi
            mkdir -p ${ANALYSISTYPE}/${ODIR}
            NXML=$(ls -1 ${BDTDIR}/${ODIR}/*.xml | wc -l)
            NROO=$(ls -1 ${BDTDIR}/${ODIR}/BDT_*[0-9].root* | wc -l)
            echo "   found $NXML XML and $NROO root files"
            cp -v -f ${BDTDIR}/${ODIR}/*.xml ${ANALYSISTYPE}/${ODIR}/
            cp -v -f ${BDTDIR}/${ODIR}/BDT_*[0-9].root ${ANALYSISTYPE}/${ODIR}/
        done
    done
done
