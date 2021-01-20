#!/bin/bash
# upload IRFs to UCLA
# - uploading in tar packages
# - one tar package per directory
# 
# prepare by hand the upload directory:
# bbftp -u bbftp -V -S -m -p 12 -e "mkdir /veritas/upload/EVNDISP/v483" gamma1.astro.ucla.edu
#

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION="v483b"

# List of directories to be uploaded
LDIR="GammaHadron_BDTs Tables RadialAcceptances"

for D in $LDIR
do
   echo "Uploading $D to /veritas/upload/EVNDISP/${VERSION}/${D}.tar"
   rm -f -v ${D}.tar
   tar -cvf ${D}.tar ${D}

   bbftp -u bbftp -V -S -m -p 12 -e "put ${D}.tar /veritas/upload/EVNDISP/${VERSION}/${D}.tar" gamma1.astro.ucla.edu
   # rm -f -v ${D}.tar
done

# Effective areas for different epochs
for F in nominalHV RedHV
do
    for I in V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
    do
       for A in ATM61 ATM62
       do
           for T in T1234 T123 T124 T134 T234
           do
               D="EffectiveAreas_${I}_${A}_${T}"
               if [[ ${F} == "RedHV" ]]; then
                   D="EffectiveAreas_${F}_${I}_${A}_${T}"
               fi
               echo "Uploading EffectiveAreas $F $I $A ${T} to /veritas/upload/EVNDISP/${VERSION}/${D}.tar "
               rm -f -v ${D}.tar
               if [[ ${F} == "RedHV" ]]; then
                   tar -cvf ${D}.tar EffectiveAreas/*${F}*${I}*${A}*${T}.root
              # (lazy inconsistency: nominal HV files contain also redHV files)
               else
                   tar -cvf ${D}.tar EffectiveAreas/*${I}*${A}*${T}.root
               fi

               bbftp -u bbftp -V -S -m -p 12 -e "put ${D}.tar /veritas/upload/EVNDISP/${VERSION}/${D}.tar" gamma1.astro.ucla.edu
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
           echo "Uploading EffectiveAreas $I $A ${T} to /veritas/upload/EVNDISP/${VERSION}/${D}.tar "
           rm -f -v ${D}.tar
           tar -cvf ${D}.tar EffectiveAreas/*${I}*${A}*${T}.root

           bbftp -u bbftp -V -S -m -p 12 -e "put ${D}.tar /veritas/upload/EVNDISP/${VERSION}/${D}.tar" gamma1.astro.ucla.edu
       done
    done
done


