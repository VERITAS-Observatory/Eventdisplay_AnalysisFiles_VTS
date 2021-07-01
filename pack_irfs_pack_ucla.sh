#!/bin/bash
# pack IRFs for UCLA
# - IRFs packed in reasonable sized tar packages
# 
# this script should be followed by put_irfs_to_ucla.sh
#

# Eventdisplay version
VERSION="v485"

# list of cuts
CLISTNV="NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Soft-TMVA-BDT NTel3-PointSource-Hard-TMVA-BDT NTel2-PointSource-Hard-TMVA-BDT NTel2-PointSource-SuperSoft NTel2-PointSource-Soft"
CLISTNV="NTel2-Extended050-Moderate-TMVA-BDT NTel2-Extended025-Moderate-TMVA-BDT"

# Radial acceptances
D="RadialAcceptances"
echo "Packing RadialAcceptances into ${D}.tar"
rm -f -v ${D}.tar
tar -cvf ${D}.tar ${D}

# Tables
for I in V4 V5 V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
do
    D="Tables_${I}"
    echo "Packing tables ${I} into ${D}.tar"
    rm -f -v ${D}.tar
    tar -cvf ${D}.tar Tables/*${I}*.root
done

# Effective areas for different epochs
for A in ATM61 ATM62
do
    for I in V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
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
               D="EffectiveAreas_${F}_${I}_${A}_${T}"
               echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar "
               rm -f -v ${D}.tar
               if [[ ${F} == "RedHV" ]]; then
                   tar -cvf ${D}.tar EffectiveAreas/*${F}*${T}*${I}*${A}*.root
               else
                   tar -cvf ${D}.tar EffectiveAreas/*${T}*${I}*${A}*.root
               fi
           done
        done
     done
done

for I in V4 V5
do
    for A in ATM21 ATM22
    do
       for T in ${CLISTNV}
       do
           D="EffectiveAreas_${I}_${A}_${T}"
           echo "Packing EffectiveAreas $F $I $A ${T} ${D}.tar "
           rm -f -v ${D}.tar
           tar -cvf ${D}.tar EffectiveAreas/*${T}*${I}*${A}*.root
       done
    done
done

