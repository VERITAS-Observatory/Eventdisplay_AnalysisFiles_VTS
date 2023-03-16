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
CLISTNV=$(cat IRF_GAMMAHADRONCUTS.dat)
CLISTRV=$(cat IRF_GAMMAHADRONCUTS_RedHV.dat)
CLISTUV=$(cat IRF_GAMMAHADRONCUTS_UV.dat)

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

pack_gammahadronbdts()
{
    echo "Packing GammaHadron BDTs"
    echo "========================"
    EPOCHS=$(cat IRF_EPOCHS_* | sort -u)
    for I in ${EPOCHS[@]} V4 V5
    do
        D="GammaHadronBDTs_${I}"
        echo "Packing BDT files ${I} into ${D}.tar"
        rm -f -v ${D}.tar
        tar -cvzf ${D}.tar GammaHadronBDTs/${I}*
        mv -f ${D}.tar ${DDIR}/
    done
}

pack_dispbdts()
{
    echo "Packing disp BDTs"
    echo "========================"
    EPOCHS=$(cat IRF_EPOCHS_* | sort -u)
    for I in ${EPOCHS[@]} V4 V5
    do
        D="DispBDTs_${I}"
        echo "Packing dispBDT files ${I} into ${D}.tar"
        rm -f -v ${D}.tar
        tar -cvzf ${D}.tar DispBDTs/${I}*
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
        # required, as IRFs for some operation mode are
        # available only for one atmosphere
        ASAVE=${A}

        for I in ${EPOCHS[@]}
        do
            # TODO for F in nominalHV RedHV UV
            for F in nominalHV RedHV
            do
                # redHV and UV for ATM61 only
               if [[ ${F} == "RedHV" ]] && [[ ${A} == "ATM62" ]]; then
                  continue
               fi
               if [[ ${F} == "UV" ]]; then
                  if [[ ${A} == "ATM62" ]]; then
                      continue
                  fi
                  A="ATM21"
                  ASAVE="ATM61"
               fi
               # list of cuts depend on observation mode
               if [[ ${F} == "RedHV" ]] && [[ -v ${CLISTRV} ]]; then
                  CLIST=${CLISTRV}
               elif [[ ${F} == "UV" ]] && [[ -v ${CLISTUV{} ]]; then
                  CLIST=${CLISTUV}
               else
                  CLIST=${CLISTNV}
               fi
               for T in $CLIST
               do
                   if [[ ${F} == "RedHV" ]] || [[ ${F} == "UV" ]]; then
                       NFIL=$(find EffectiveAreas -name "*${F}*${T}*${I}*${A}*.root" | wc -l)
                   else
                       NFIL=$(find EffectiveAreas -name "*${T}*${I}*${A}*.root" | wc -l)
                   fi
                   if [[ $NFIL != "0" ]]; then
                       D="EffectiveAreas_${F}_${I}_${A}_${T}"
                       echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar ($NFIL files)"
                       rm -f -v ${D}.tar
                       if [[ ${F} == "RedHV" ]] || [[ ${F} == "UV" ]]; then
                           tar -cvf ${D}.tar EffectiveAreas/*${F}*${T}*${I}*${A}*.root
                       else
                           tar -cvf ${D}.tar EffectiveAreas/*${T}*${I}*${A}*.root
                       fi
                       mv -v ${D}.tar ./${DDIR}/
                   else
                       echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar (no files)"
                   fi
               done
               A=${ASAVE}
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

pack_lookup_tables

pack_effectiveareas_V6

# TODO pack_effectivareas_V4V5

pack_dispbdts

pack_gammahadronbdts

echo "Observe the TODOs in this scripts before the release"
