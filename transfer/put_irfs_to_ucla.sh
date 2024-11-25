#!/bin/bash
# Upload IRFs to UCLA (using bbftp)
#
# - uploading in tar packages
# - one tar package per directory
#
# prepare by hand the upload directory:
# bbftp -u bbftp -V -S -m -p 12 -e "mkdir /veritas/upload/EVNDISP/v491" gamma1.astro.ucla.edu
#

[[ "$1" ]] && IRFTYPE=$1 || IRFTYPE=""

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION=$(cat ../IRFMINORVERSION)
if [[ $IRFTYPE ]]; then
   VERSION=${VERSION}${IRFTYPE}
fi

echo "Uploading to /veritas/upload/EVNDISP/${VERSION}/"

cd ..

# list of tar files
TARLIST=$(find tar_packages_${VERSION}/ -name "*.tar")

for T in ${TARLIST}
do
   TT=$(basename "$T")
   echo "$T" "$TT"
   bbftp -u bbftp -V -S -m -p 12 -e "put ${T} /veritas/upload/EVNDISP/${VERSION}/${TT}" gamma1.astro.ucla.edu
done
