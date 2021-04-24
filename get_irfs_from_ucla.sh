#!/bin/bash
# download IRFs from UCLA
# - downloading in tar packages
# - one tar package per directory,
#   except for effective areas
# 

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION="v485"

# List of directories to be uploaded
LDIR="Tables RadialAcceptances"

for D in $LDIR
do
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
done

for F in nominalHV RedHV
do
# Effective areas for different epochs
    for I in V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
    do
       for A in ATM61 ATM62
       do
           for T in T1234 T123 T124 T134 T234
           do
               D="EffectiveAreas_${I}_${A}_${T}"
               if [[ ${F} == "RedHV" ]]; then
                  D="EffectiveAreas_${F}_${I}_${A}_${T}"
                  # no redHV files for ATM62
                  if [[ $A == "ATM62" ]]; then
                     continue
                  fi
               fi
               echo "Getting EffectiveAreas ${F} $I $A ${T} (${D}.tar)"
               if [[ $HOSTNAME == *"desy"* ]]; then
                   cp -v -i /lustre/fs23/group/veritas/Eventdisplay_AnalysisFiles/${VERSION}/archive/$D.tar .
               else
                   bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D}.tar ${D}.tar" gamma1.astro.ucla.edu
               fi
               tar --keep-newer-files -xvf ${D}.tar
               rm -v ${D}.tar
           done
        done
    done
done

for I in V4 V5
do
    for A in ATM21 ATM22
    do
       for T in T1234 T123 T124 T134 T234
       do
           D="EffectiveAreas_${I}_${A}_${T}"
           echo "Getting EffectiveAreas $I $A ${T} (${D}.tar)"
           if [[ $HOSTNAME == *"desy"* ]]; then
               cp -v -i /lustre/fs23/group/veritas/Eventdisplay_AnalysisFiles/${VERSION}/archive/$D.tar .
           else
               bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D}.tar ${D}.tar" gamma1.astro.ucla.edu
           fi
           tar --keep-newer-files -xvf ${D}.tar
           rm -v ${D}.tar
       done
    done
done


