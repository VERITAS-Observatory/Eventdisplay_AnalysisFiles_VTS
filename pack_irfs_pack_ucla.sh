#!/bin/bash
# pack IRFs for UCLA
# - IRFs packed in reasonable sized tar packages
# 
# this script should be followed by put_irfs_to_ucla.sh
#

# directory with all packages
DDIR="tar_packages"
mkdir -p ${DDIR}

# list of cuts
CLISTNV="NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Soft-TMVA-BDT NTel3-PointSource-Hard-TMVA-BDT NTel2-PointSource-Hard-TMVA-BDT NTel2-PointSource-SuperSoft NTel2-PointSource-Soft NTel2-Extended050-Moderate-TMVA-BDT NTel2-Extended025-Moderate-TMVA-BDT"
CLISTRV="NTel2-PointSource-Soft-GEO NTel2-PointSource-SuperSoft"

pack_radial_acceptances()
{
    echo "Packing Radial acceptances"
    echo "=========================="
    D="RadialAcceptances"
    echo "Packing RadialAcceptances into ${D}.tar"
    rm -f -v ${D}.tar
    tar -cvf ${D}.tar ${D}
    mv -v -f ${D}.tar ${DDIR}/
}

pack_lookup_tables()
{
    echo "Packing Lookup Tables"
    echo "====================="
    EPOCHS=$(cat IRF_EPOCHS_* | sort -u)
    for I in ${EPOCHS[@]} V4 V5
    do
        D="Tables_${I}"
        echo "Packing tables ${I} into ${D}.tar"
        rm -f -v ${D}.tar
        tar -cvf ${D}.tar Tables/*${I}*.root
        mv -f ${D}.tar ${DDIR}/
    done
}

pack_effectiveareas_V6()
{
    # Effective areas for different epochs
    for A in ATM61 ATM62
    do
        if [[ ${A} == "ATM62" ]]; then
            EPOCHS=$(cat IRF_EPOCHS_SUMMER.dat | sort -u)
        else
            EPOCHS=$(cat IRF_EPOCHS_WINTER.dat | sort -u)
        fi

        for I in ${EPOCHS[@]}
        do
            for F in nominalHV RedHV
            do
               if [[ ${F} == "RedHV" ]] && [[ ${A} == "ATM62" ]]; then
                  continue
               fi
               if [[ ${F} == "RedHV" ]]; then
                  CLIST=${CLISTRV}
               else
                  CLIST=${CLISTNV}
               fi
               for T in $CLIST
               do
                   if [[ ${F} == "RedHV" ]]; then
                       NFIL=$(find EffectiveAreas -name "*${F}*${T}*${I}*${A}*.root" | wc -l)
                   else
                       NFIL=$(find EffectiveAreas -name "*${T}*${I}*${A}*.root" | wc -l)
                   fi
                   if [[ $NFIL != "0" ]]; then
                       D="EffectiveAreas_${F}_${I}_${A}_${T}"
                       echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar ($NFIL files)"
                       rm -f -v ${D}.tar
                       if [[ ${F} == "RedHV" ]]; then
                           tar -cvf ${D}.tar EffectiveAreas/*${F}*${T}*${I}*${A}*.root
                       else
                           tar -cvf ${D}.tar EffectiveAreas/*${T}*${I}*${A}*.root
                       fi
                       mv -v ${D}.tar ./${DDIR}/
                   else
                       echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar (no files)"
                   fi
               done
            done
         done
    done
}

pack_effectivareas_V4V5()
{
    echo "Packing Effective Areas V4 V5"
    echo "============================="
    for I in V4 V5
    do
        for A in ATM21 ATM22
        do
           for T in ${CLISTNV}
           do
               NFIL=$(find EffectiveAreas -name "*${T}*${I}*${A}*.root" | wc -l)
               if [[ $NFIL != "0" ]]; then
                   D="EffectiveAreas_${I}_${A}_${T}"
                   echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar ($NFIL files)"
                   rm -f -v ${D}.tar
                   tar -cvf ${D}.tar EffectiveAreas/*${T}*${I}*${A}*.root
                   mv -v ${D}.tar ./${DDIR}/
               else
                  echo "Packing EffectiveAreas $F $I $A ${T} (no files found)" 
               fi
           done
        done
    done
}

# pack_radial_acceptances

# pack_lookup_tables

pack_effectiveareas_V6

# pack_effectivareas_V4V5

