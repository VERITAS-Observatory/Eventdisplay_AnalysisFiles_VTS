#!/bin/bash
# download IRFs from UCLA
# - downloading in tar packages
# - one tar package per directory,
#   except for effective areas
# 

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION=$(cat IRFVERSION)

# list of cuts
CLISTRV="NTel2-PointSource-SuperSoft NTel2-PointSource-Soft"
CLISTNV="NTel2-Extended050-Moderate-TMVA-BDT NTel2-Extended025-Moderate-TMVA-BDT"
CLISTNV="NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Soft-TMVA-BDT NTel3-PointSource-Hard-TMVA-BDT NTel2-PointSource-Hard-TMVA-BDT"

## function to download and upack
download_and_unpack()
{
    D=${1}
    if [[ $HOSTNAME == *"desy"* ]]; then
       echo "DESY host detected"
       cp -v -i /lustre/fs23/group/veritas/Eventdisplay_AnalysisFiles/${VERSION}/archive/$D.tar .
    else
       echo "Downloading $D.tar from  /veritas/upload/EVNDISP/${VERSION}/${D}"
       if [[ -e ${D}.tar ]]
       then
           echo "   File ${D}.tar exists locally"
           echo "   move or remove before resume downloading"
           continue
       fi
       bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D}.tar ${D}.tar" gamma1.astro.ucla.edu
   fi
   tar --keep-newer-files -xvf ${D}.tar
   rm -v ${D}.tar
}


# Radial acceptances
download_and_unpack RadialAcceptances

# Tables
for I in V4 V5 V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
do
  download_and_unpack Tables_${I}
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
              download_and_unpack ${D}
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
           download_and_unpack ${D}
       done
    done
done

