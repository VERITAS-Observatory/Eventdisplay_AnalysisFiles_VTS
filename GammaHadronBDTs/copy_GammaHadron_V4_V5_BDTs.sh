#!/bin/bash
# copy gamma/hadron BDT files from IRF production site 
# (V4/V5 epochs)
#
# hardwired 
# - ANALYSISTYPE (e.g., AP)
# - Directory with BDT output
#

ANALYSISTYPE="AP"

echo "COPY gamma/hadron BDTs for ${IRVERSION}, analysis type ${ANALYSISTYPE}"

for A in ATM21 ATM22
do
    if [[ ${A} == "ATM62" ]]; then
        EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
    else
        EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
    fi
    for E in V4 V5
    do
        BDTDIR="$VERITAS_USER_DATA_DIR/analysis/Results/v490/AP/BDTtraining/GammaHadronBDTs_${E}_DISP/"
        echo "  reading files from ${BDTDIR}"

        for C in NTel2-Moderate NTel2-Soft NTel3-Hard
        do
            echo "EPOCH ${E} CUT ${C}"
            ODIR="${E}_${A}/${C}"
            if [[ ! -d ${BDTDIR}/${ODIR} ]]; then
                echo "   directory not found"
                continue
            fi
            mkdir -p ${ODIR}
            NXML=$(ls -1 ${BDTDIR}/${ODIR}/*.xml | wc -l)
            NROO=$(ls -1 ${BDTDIR}/${ODIR}/BDT_*[0-9].root* | wc -l)
            echo "   found $NXML XML and $NROO root files"
            cp -v -f ${BDTDIR}/${ODIR}/*.xml ${ODIR}/
            cp -v -f ${BDTDIR}/${ODIR}/BDT_*[0-9].root ${ODIR}/
        done
    done
done
