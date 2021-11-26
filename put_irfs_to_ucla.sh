#!/bin/bash
# upload IRFs to UCLA
# - uploading in tar packages
# - one tar package per directory
# 
# prepare by hand the upload directory:
# bbftp -u bbftp -V -S -m -p 12 -e "mkdir /veritas/upload/EVNDISP/v485b" gamma1.astro.ucla.edu
#

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION=$(cat IRFVERSION)

# list of tar files
TARLIST=$(find tar_packages -name "*.tar")

for T in ${TARLIST}
do
   TT=$(basename $T)
   echo $T $TT
   bbftp -u bbftp -V -S -m -p 12 -e "put ${T} /veritas/upload/EVNDISP/${VERSION}/${TT}" gamma1.astro.ucla.edu
done
