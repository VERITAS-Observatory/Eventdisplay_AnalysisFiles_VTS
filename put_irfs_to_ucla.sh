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
VERSION="v483"

# List of directories to be uploaded
LDIR="GammaHadron_BDTs Tables RadialAcceptances EffectiveAreas"

for D in $LDIR
do
   echo "Uploading $D to /veritas/upload/EVNDISP/${VERSION}/${D}.tar"
   rm -f -v ${D}.tar
   tar -cvf ${D}.tar ${D}

   bbftp -u bbftp -V -S -m -p 12 -e "put ${D}.tar /veritas/upload/EVNDISP/${VERSION}/${D}.tar" gamma1.astro.ucla.edu
   # rm -f -v ${D}.tar
done
