#!/bin/bash
# download IRFs from UCLA
#

VERSION=$(cat IRFVERSION)
VERSION="${VERSION}.5"

if [ -z "$1" ]; then
echo "
./download_irfs.sh <filelist>

download IRFs from UCLA for Eventdisplay version $VERSION

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

FILES=$(cat "${1}")
for D in ${FILES}
do
    if [[ $HOSTNAME == *"desy"* ]]; then
       cp -v -i "$VERITAS_DATA_DIR"/shared/Eventdisplay_AnalysisFiles/"${VERSION}"/"$D" .
    else
       echo "Downloading $D from  /veritas/upload/EVNDISP/${VERSION}/${D}"
       if [[ -e ${D} ]]
       then
           echo "   File ${D} exists locally"
           echo "   move or remove before resume downloading"
           continue
       fi
       bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D} ${D}" gamma1.astro.ucla.edu
   fi
   tar --keep-newer-files -xvf "${D}"
   rm -v "${D}"
done
