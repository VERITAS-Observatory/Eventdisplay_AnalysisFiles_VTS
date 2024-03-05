#!/bin/bash
# copy gamma/hadron BDT files from IRF production site
#
# hardwired
# - ANALYSISTYPE (e.g., AP)
# - Directory with BDT output
#

IRFVERSION=$(cat ../IRFVERSION)
ANALYSISTYPE="${VERITAS_ANALYSIS_TYPE:0:2}"

BDTDIR="$VERITAS_USER_DATA_DIR/analysis/Results/v490/${ANALYSISTYPE}/BDTtraining/GammaHadronBDTs_V6_DISP/"
if [[ $ANALYSISTYPE == "AP" ]]; then
    CUTLIST="NTel2-Moderate NTel2-Soft NTel2-Hard NTel3-Hard"
else
    CUTLIST="NTel2-SuperSoft"
fi

echo "COPY gamma/hadron BDTs for ${IRFVERSION}, analysis type ${ANALYSISTYPE}"
echo "  reading files from ${BDTDIR}"

for A in ATM61 ATM62
do
    if [[ ${A} == "ATM62" ]]; then
        EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat | sort -u)
    else
        EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat | sort -u)
    fi
    # FIXEPOCH EPOCHS="V6_2023_2023s"
    for E in $EPOCHS
    do
        for C in $CUTLIST
        do
            echo "EPOCH ${E} CUT ${C}"
            IDIR="${E}_${A}/${C}"
            ODIR="${IDIR}"
            # NN cleaning exist for supersoft only
            # (same as soft cleaning)
            if [[ $ANALYSISTYPE == "NN" ]]; then
                ODIR="${E}_${A}/${C/NTel2-Soft/NTel2-SuperSoft}"
            fi
            if [[ ! -d ${BDTDIR}/${IDIR} ]]; then
                echo "   directory not found"
                continue
            fi
            mkdir -p ${ANALYSISTYPE}/${ODIR}
            NXML=$(ls -1 ${BDTDIR}/${IDIR}/*.xml | wc -l)
            NROO=$(ls -1 ${BDTDIR}/${IDIR}/BDT_*[0-9].root* | wc -l)
            echo "   found $NXML XML and $NROO root files"
            cp -v -f ${BDTDIR}/${IDIR}/*.xml ${ANALYSISTYPE}/${ODIR}/
            cp -v -f ${BDTDIR}/${IDIR}/BDT_*[0-9].root ${ANALYSISTYPE}/${ODIR}/
        done
    done
done
