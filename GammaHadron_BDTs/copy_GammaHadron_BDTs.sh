#!/bin/bash
# copy gamma/hadron BDT files from IRF production site
#
# hardwired 
# - SIMTYPE (e.g., CARE_June2020)
# - ANALYSISTYPE (e.g., AP)
# - Directory with BDT output
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="AP"
SIMTYPE="CARE_June2020"

BDTDIR="$VERITAS_USER_DATA_DIR/analysis/Results/v490/AP/BDTtraining"

echo "COPY gamma/hadron BDTs for ${IRVERSION}, analysis type ${ANALYSISTYPE}, and simulation type ${SIMTYPE}"
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
            mkdir -p ${ODIR}
            ls  ${BDTDIR}/${ODIR}/*
            continue
            cp -v -f ${BDTDIR}/${ODIR}/*.xml ${ODIR}/
            cp -v -f ${BDTDIR}/${ODIR}/BDT_*.root ${ODIR}/
        done
    done
done
