#!/bin/bash
# download IRFs from UCLA
# - downloading in tar packages
# - one tar package per directory
# 

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION="v483"

# List of directories to be uploaded
LDIR=( "EffectiveAreas"  "GammaHadron_BDTs" "RadialAcceptances" "Tables" )

for D in $LDIR
do
   echo "Downloading $D.tar.gz from  /veritas/upload/EVNDISP/${VERSION}/${D}"
   if [[ -e ${D}.tar.gz ]]
   then
       echo "   File ${D}.tar.gz exists locally"
       echo "   move or remove before resume downloading"
       continue
   fi
   bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D}.tar.gz ${D}.tar.gz" gamma1.astro.ucla.edu
   tar --keep-newer-files -xvzf ${D}.tar.gz
   rm -f -v ${D}.tar.gz
done
