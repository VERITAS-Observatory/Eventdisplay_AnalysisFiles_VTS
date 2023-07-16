#!/bin/bash
# pack IRFs for UCLA
# - IRFs packed in reasonable sized tar packages
# 
# this script should be followed by put_irfs_to_ucla.sh
#

# directory with all packages
DDIR="tar_packages_v490.2"

# list of cuts
CLISTNV=$(cat ../IRF_GAMMAHADRONCUTS.dat)
CLISTNN=$(cat ../IRF_GAMMAHADRONCUTS_NN.dat)
CLISTRV=$(cat ../IRF_GAMMAHADRONCUTS_RedHV.dat)
CLISTUV=$(cat ../IRF_GAMMAHADRONCUTS_UV.dat)

# cleaning types
CLEANING="AP NN"

P=$(pwd)
cd ..
mkdir -p ${DDIR}

get_epochs()
{
    EPOCHS=$(cat IRF_EPOCHS_* | sort -u)
    if [[ $1 = "NN" ]]; then
        TEPOCHS="${EPOCHS[@]}"
    else
        TEPOCHS="${EPOCHS[@]} V4 V5"
    fi
    echo "$TEPOCHS"
}


pack_lookup_tables()
{
    echo "Packing Lookup Tables"
    echo "====================="
    for C in ${CLEANING}
    do
        EPOCHS=$(get_epochs $C)
        for I in ${EPOCHS[@]}
        do
            D="Tables_${C}_${I}"
            echo "Packing tables ${I} into ${D}.tar"
            rm -f -v ${D}.tar
            tar -cvf ${D}.tar Tables/*${I}*${C}*.root
            mv -f ${D}.tar ${DDIR}/
        done
    done
    }

pack_gammahadronbdts()
{
    echo "Packing GammaHadron BDTs"
    echo "========================"
    for C in ${CLEANING}
    do
        EPOCHS=$(cat IRF_EPOCHS_* | sort -u)
        for I in ${EPOCHS[@]} V4 V5
        do
            D="GammaHadronBDTs_${C}_${I}"
            echo "Packing BDT files ${I} into ${D}.tar"
            rm -f -v ${D}.tar
            tar -cvzf ${D}.tar GammaHadronBDTs/${C}/${I}*
            mv -f ${D}.tar ${DDIR}/
        done
    done
}

pack_dispbdts()
{
    echo "Packing disp BDTs"
    echo "========================"
    for C in ${CLEANING}
    do
        EPOCHS=$(get_epochs $C)
        for I in ${EPOCHS[@]} V4 V5
        do
            D="DispBDTs_${C}_${I}"
            echo "Packing dispBDT files ${I} into ${D}.tar"
            if [[ -e DispBDTs/${C} ]]; then
                rm -f -v ${D}.tar
                tar -cvzf ${D}.tar DispBDTs/${C}/${I}*
                mv -f ${D}.tar ${DDIR}/
            else
                echo "ERROR directory DispBDTs/${C}/ does not exist"
            fi    
        done
    done
}

pack_effectiveareas_V6()
{
    for C in ${CLEANING}
    do
        for F in nominalHV RedHV
        do
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
                    # UV for ATM61 only
                   if [[ ${F} == "UV" ]]; then
                      if [[ ${A} == "ATM62" ]]; then
                          continue
                      fi
                      A="ATM21"
                      ASAVE="ATM61"
                   fi
                   # list of cuts depend on observation mode
                   if [[ ${C} == "NN" ]]; then
                      CLIST=${CLISTNN}
                   elif [[ ${F} == "RedHV" ]]; then
                      CLIST=${CLISTRV}
                   elif [[ ${F} == "UV" ]]; then
                      CLIST=${CLISTUV}
                   else
                      CLIST=${CLISTNV}
                   fi
                   for T in $CLIST
                   do
                       if [[ ${F} == "RedHV" ]] || [[ ${F} == "UV" ]]; then
                           NFIL=$(find EffectiveAreas -name "*${F}*${T}*${C}*${I}*${A}*.root" | wc -l)
                       else
                           NFIL=$(find EffectiveAreas -name "*${T}*${C}*${I}*${A}*.root" | wc -l)
                       fi
                       echo "FFFFFFF $NFIL"
                       if [[ $NFIL != "0" ]]; then
                           D="EffectiveAreas_${F}_${C}_${I}_${A}_${T}"
                           echo "Packing EffectiveAreas $F $C $I $A ${T} ${D}.tar ($NFIL files)"
                           rm -f -v ${D}.tar
                           if [[ ${F} == "RedHV" ]] || [[ ${F} == "UV" ]]; then
                               tar -cvf ${D}.tar EffectiveAreas/*${F}*${T}*${C}*${I}*${A}*.root
                           else
                               tar -cvf ${D}.tar EffectiveAreas/*${T}*${C}*${I}*${A}*.root
                           fi
                           mv -v ${D}.tar ./${DDIR}/
                       else
                           echo "Packing EffectiveAreas $F $C $I $A ${T} ${D}.tar (no files)"
                       fi
                   done
                   A=${ASAVE}
                done
             done
        done
    done
}

pack_effectivareas_V4V5()
{
    echo "Packing Effective Areas V4 V5"
    echo "============================="
    for C in ${CLEANING}
    do
        if [[ $C = "NN" ]]; then
            continue
        fi
        for I in V4 V5
        do
            for A in ATM21 ATM22
            do
               for T in ${CLISTNV}
               do
                   NFIL=$(find EffectiveAreas -name "*${T}*${C}*${I}*${A}*.root" | wc -l)
                   if [[ $NFIL != "0" ]]; then
                       D="EffectiveAreas_${C}_${I}_${A}_${T}"
                       echo "Packing EffectiveAreas $F ${C} $I $A ${T} ${D}.tar ($NFIL files)"
                       rm -f -v ${D}.tar
                       tar -cvf ${D}.tar EffectiveAreas/*${T}*${C}*${I}*${A}*.root
                       mv -v ${D}.tar ./${DDIR}/
                   else
                      echo "Packing EffectiveAreas $F ${C} $I $A ${T} (no files found)" 
                   fi
               done
            done
        done
    done
}

pack_lookup_tables

pack_effectiveareas_V6

pack_effectivareas_V4V5

pack_dispbdts
 
pack_gammahadronbdts

cd ${P}
