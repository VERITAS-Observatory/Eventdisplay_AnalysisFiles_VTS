#!/bin/bash
# download IRFs from UCLA
#

VERSION=$(cat IRFVERSION)
VERSION="${VERSION}.0"

if [ ! -n "$1" ]; then
echo "
./download_irfs.sh <filelist>

download IRFs from UCLA for Eventdisplay version $VERSION

   <server>  UCLA or DESY
   <filelist> list of tar packages to be downloaded 
              (usually found in directory ./transfer)

"
exit
fi

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

if [[ ! -e ${1} ]]; then
    echo "Error - file list ${1} not found"
    exit
fi

echo "Downloading IRF packages for ${VERSION}/"

FILES=$(cat ${1})
for D in ${FILES}
do
    if [[ $HOSTNAME == *"desFFy"* ]]; then
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
