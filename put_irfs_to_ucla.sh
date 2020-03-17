#!/bin/bash
# upload IRFs to UCLA
# - uploading in tar packages
# - one tar package per directory
# 
# prepare by hand the upload directory:
# bbftp -u bbftp -V -S -m -p 12 -e "mkdir /veritas/upload/EVNDISP/v482" gamma1.astro.ucla.edu
#

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION="v482"

# List of directories to be uploaded
LDIR="GammaHadron_BDTs Tables"

for D in $LDIR
do
   echo "Uploading $D to /veritas/upload/EVNDISP/${VERSION}/${D}.tar.gz"
   rm -f -v ${D}.tar.gz
   tar -cvzf ${D}.tar.gz ${D}

   bbftp -u bbftp -V -S -m -p 12 -e "put ${D}.tar.gz /veritas/upload/EVNDISP/${VERSION}/${D}.tar.gz" gamma1.astro.ucla.edu
   rm -f -v ${D}.tar.gz
done
