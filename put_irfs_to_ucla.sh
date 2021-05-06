#!/bin/bash
# upload IRFs to UCLA
# - uploading in tar packages
# - one tar package per directory
# 
# prepare by hand the upload directory:
# bbftp -u bbftp -V -S -m -p 12 -e "mkdir /veritas/upload/EVNDISP/v485" gamma1.astro.ucla.edu
#

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION="v485"

# list of tar files
TARLIST=$(find . -maxdepth 1 -name "*.tar")

for T in ${TARLIST}
do
   bbftp -u bbftp -V -S -m -p 12 -e "put ${T} /veritas/upload/EVNDISP/${VERSION}/${T}" gamma1.astro.ucla.edu
done
